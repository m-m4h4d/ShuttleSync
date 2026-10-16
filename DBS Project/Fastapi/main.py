import os
from datetime import datetime, timedelta
from typing import List
from zoneinfo import ZoneInfo

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from database import get_connection
from models import Arrival, Shuttle, Stop, StopArrivals

CAMPUS_TIMEZONE = ZoneInfo(os.getenv("CAMPUS_TIMEZONE", "Asia/Karachi"))

app = FastAPI(title="ShuttleSync API")

origins = [
    origin.strip()
    for origin in os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")
    if origin.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_methods=["GET"],
    allow_headers=["*"],
)


def format_time(value):
    """MySQL TIME columns arrive as timedelta; render them as HH:MM:SS."""
    if value is None:
        return None
    if isinstance(value, timedelta):
        total = int(value.total_seconds())
        return f"{total // 3600:02d}:{total % 3600 // 60:02d}:{total % 60:02d}"
    return str(value)


def to_stop(row) -> Stop:
    return Stop(id=row["idStops"], name=row["Name"], offset=format_time(row["Duration"]))


@app.get("/")
def root():
    return {"message": "ShuttleSync API", "docs": "/docs"}


@app.get("/api/health")
def health():
    with get_connection() as connection, connection.cursor() as cursor:
        cursor.execute("SELECT 1")
    return {"status": "ok"}


@app.get("/api/stops", response_model=List[Stop])
def get_stops():
    with get_connection() as connection, connection.cursor() as cursor:
        cursor.execute("SELECT idStops, Name, Duration FROM Stops ORDER BY idStops")
        return [to_stop(row) for row in cursor.fetchall()]


@app.get("/api/shuttles", response_model=List[Shuttle])
def get_shuttles():
    with get_connection() as connection, connection.cursor() as cursor:
        cursor.execute(
            "SELECT idShuttles, StartTime, Available, Cycles FROM Shuttles ORDER BY idShuttles"
        )
        return [
            Shuttle(
                id=row["idShuttles"],
                start_time=format_time(row["StartTime"]),
                available=bool(row["Available"]),
                cycles=row["Cycles"],
            )
            for row in cursor.fetchall()
        ]


@app.get("/api/stops/{stop_id}/arrivals", response_model=StopArrivals)
def get_arrivals(stop_id: int):
    campus_time = datetime.now(CAMPUS_TIMEZONE).strftime("%H:%M:%S")

    with get_connection() as connection, connection.cursor() as cursor:
        cursor.execute(
            "SELECT idStops, Name, Duration FROM Stops WHERE idStops = %s", (stop_id,)
        )
        stop = cursor.fetchone()
        if stop is None:
            raise HTTPException(status_code=404, detail="Stop not found")

        cursor.execute("CALL next_arrivals(%s, %s)", (stop_id, campus_time))
        rows = cursor.fetchall()

    return StopArrivals(
        stop=to_stop(stop),
        campus_time=campus_time,
        arrivals=[
            Arrival(
                shuttle_id=row["ShuttleID"],
                start_time=format_time(row["StartTime"]),
                available=bool(row["Available"]),
                arrival_time=format_time(row["ArrivalTime"]),
                seconds_until=row["SecondsUntil"],
            )
            for row in rows
        ],
    )

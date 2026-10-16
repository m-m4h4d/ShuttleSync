from typing import List, Optional

from pydantic import BaseModel


class Stop(BaseModel):
    id: int
    name: str
    offset: Optional[str]


class Shuttle(BaseModel):
    id: int
    start_time: str
    available: bool
    cycles: int


class Arrival(BaseModel):
    shuttle_id: int
    start_time: str
    available: bool
    arrival_time: Optional[str]
    seconds_until: Optional[int]


class StopArrivals(BaseModel):
    stop: Stop
    campus_time: str
    arrivals: List[Arrival]

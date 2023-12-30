from fastapi import FastAPI, HTTPException, Depends, status, Request
from pydantic import BaseModel
from typing import Annotated, List
import models
from database import engine, SessionLocal
from sqlalchemy.orm import Session
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
origins = ["http://localhost:3000"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class ShuttleBase(BaseModel):
    starttime: int
    isavailable: bool


class ShuttleModel(ShuttleBase):
    shuttleid: int
    starttime: int
    isavailable: bool

    class Config:
        orm_mode = True


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


db_dependency = Annotated[Session, Depends(get_db)]
models.Base.metadata.create_all(bind=engine)


@app.post("/shuttle/", response_model=ShuttleModel)
async def create_shuttle(shuttle: ShuttleBase, db: db_dependency):
    print("responxse")
    db_shuttle = models.Shuttles(**shuttle.model_dump())
    db.add(db_shuttle)
    db.commit()
    db.refresh(db_shuttle)

    return db_shuttle


@app.get("/shuttle/", response_model=List[ShuttleModel])
async def get_shuttle(db: db_dependency, skip: int = 0, limit: int = 100):
    shuttles = db.query(models.Shuttles).offset(skip).limit(limit).all()

    return shuttles

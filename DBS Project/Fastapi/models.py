from sqlalchemy import Boolean, Column, Integer, String
from database import Base


class Shuttles(Base):
    __tablename__ = "Shuttles"

    shuttleid = Column(Integer, primary_key=True)
    starttime = Column(Integer)
    isavailable = Column(Boolean)

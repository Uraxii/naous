import sqlalchemy
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import sessionmaker, Session

from services.peer_manager import PeerManager

#region Dependency Values
DATABASE_URL = "sqlite:///./naous.db"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

peer_manager = PeerManager()
#endregion

#region Dependency Getter Methods
def get_peer_manager() -> PeerManager:
    return peer_manager


def get_db():
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()
#endregion


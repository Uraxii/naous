from pymongo import MongoClient
from pymongo.database import Database

from core.config import settings
from services.peer_manager import PeerManager


peer_manager: PeerManager = PeerManager()

client: MongoClient = MongoClient(
    host=settings.DATABASE_URI,
    port=settings.DATABASE_PORT,
    connect=True)

#db: Database = client[settings.DATABASE_NAME]

#region Dependency Getter Methods
def get_peer_manager() -> PeerManager:
    return peer_manager


def get_client() -> MongoClient:
    return client
#endregion


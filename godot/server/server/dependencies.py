from services.peer_manager import PeerManager


peer_manager = PeerManager()


def get_peer_manager() -> PeerManager:
    return peer_manager

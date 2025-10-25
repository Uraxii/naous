import asyncio

from fastapi import WebSocket
from models.peer import InactiveSession, Peer


class PeerManager():
    _singleton = None

    # Peer ID : Peer
    active_peers: dict[int, Peer] = {}
    inactive_peers: dict[int, Peer] = {}
    # Session_tokens : Inactive Sessions
    inactive_sessions: dict[str, InactiveSession] = {}

    # 0 = No ID
    # 1 = Server ID
    next_id = 2
    released_ids: list[int] = []


    def __new__(cls):
        # Ensures we do only ever create one instance of the singleton
        if cls._singleton:
            return cls._singleton

        print("Creating a new PeerManager instance...")
        cls._singleton = super(PeerManager, cls).__new__(cls)
        return cls._singleton


    def __init__(self):
        self.should_remove_dead_connections: bool = False


    def get_peer(self, peer_id: int) -> Peer | None:
        return self.active_peers.get(peer_id)


    def reserve_next_id(self) -> int:
        id: int
        if len(self.released_ids) > 0:
            id = self.released_ids.pop()
        else:
            id = self.next_id
            self.next_id += 1
        return id


    def release_id(self, peer_id) -> None:
        self.released_ids.append(peer_id)


    def create_peer(self, websocket: WebSocket) -> Peer | None:
        peer = Peer()
        peer.id = self.reserve_next_id()
        peer.socket = websocket
        self.inactive_peers[peer.id] = peer
        return peer


    def add_inactive_session(self, inactive_session: InactiveSession) -> None:
        session_token = inactive_session.session.token
        self.inactive_sessions[session_token] = inactive_session


    def activate_peer(
            self,
            peer: Peer,
            session_token: str
    ) -> int:
        inactive_session = self.inactive_sessions.get(session_token)
        if not inactive_session:
            print("Failed to find inactive session token.")
            return 0

        del self.inactive_sessions[inactive_session.session.token]

        peer.session = inactive_session.session
        peer.user = inactive_session.user
        self.active_peers[peer.id] = peer
        return peer.id


    def deactivate_peer(self, peer_id: int) -> Peer | None:
        peer = self.active_peers.get(peer_id)
        if not peer:
            return

        del self.active_peers[peer.id]
        self.inactive_peers[peer.id] = peer
        return peer


    async def remove_expired_peers(self) -> list[Peer]:
        expired_peers = []

        for peer in self.inactive_peers.values():
            if peer.session.is_expired():
                expired_peers.append(peer)

        for peer in expired_peers:
            print(f"Removing {peer.debug_name}")
            del self.inactive_peers[peer.id]
            self.release_id(peer.id)

        return expired_peers


    async def start_removing_expired_peers_async(
            self,
            interval_sec: float
    ) -> None:
        self.stop_removing_expired_peers()

        self.should_remove_dead_connections = True
        asyncio.get_running_loop().create_task(
            self._run_remove_expired_peers(interval_sec))


    def stop_removing_expired_peers(self) -> None:
        self.should_remove_dead_connections = False


    async def _run_remove_expired_peers(self, interval_sec) -> None:
        while self.should_remove_dead_connections:
            await self.remove_expired_peers()
            await asyncio.sleep(interval_sec)


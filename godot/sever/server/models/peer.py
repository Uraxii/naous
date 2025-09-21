from __future__ import annotations
import random
import string
from datetime import datetime, timedelta
from fastapi import WebSocket
from pydantic import BaseModel
from typing import TYPE_CHECKING

from .game import Character, User
from .packets import Packet


if TYPE_CHECKING:
    from .states import ConnectionState



class Session():
    def __init__(self, time_to_live: timedelta):
        self.token = self.refresh_token()
        self.expiration = datetime.now() + time_to_live


    def refresh_token(self) -> str:
        # TODO: TRANSITON TO JWT!!!
        self.token = "NOT-SECURE-MAKE-JWT-" + generate_random_string(512)
        return self.token


    def is_expired(self) -> bool:
        return self.expiration < datetime.now()


class InactiveSession():
    def __init__(self, session: Session, user: User) -> None:
        self.session: Session = session
        self.user: User = user


class Peer():
    id: int = 0
    socket: WebSocket
    current_state: ConnectionState
    session: Session
    user: User = User(id="NO-ID", name="Unauthenticated Peer", roles=[])
    character: Character


    @property
    def debug_name(self) -> str:
        return f"{self.user.name} ({self.id})"


    def is_valid_token(self, session_token: str) -> bool:
        return session_token == self.session.token


    async def send_packet(self, packet: BaseModel):
        json_str = packet.model_dump_json(exclude={'session_token'})
        print(f"Sending packet to {self.debug_name}: {json_str}")
        await self.socket.send_text(json_str)


    def set_state(self, new_state: ConnectionState):
        self.current_state = new_state


    async def handle_packet(self, packet: Packet):
        await self.current_state.handle_packet(packet)


def generate_random_string(length):
    characters = string.ascii_letters + string.digits
    random_string = ''.join(random.choices(characters, k=length))
    return random_string


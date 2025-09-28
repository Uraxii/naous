from abc import ABC, abstractmethod
from typing import Callable

from dependencies import get_peer_manager
from models.peer import Peer
from .packets import *


class ConnectionState(ABC):
    def __init__(self, peer: Peer):
        self.peer_manager = get_peer_manager()
        self.peer = peer


    @abstractmethod
    async def handle_packet(self, packet: Packet) -> None:
        pass


    @staticmethod
    async def handle_claim_token(
            peer: Peer,
            packet: Packet[ClaimTokenReq]
    ) -> None:
        print("Got claim token packet.")

        peer_manager = get_peer_manager()

        token_to_claim = packet.payloads.session_token_to_claim
        if not token_to_claim:
            print("Token to claim is empty!")
            return

        peer_id = peer_manager.activate_peer(peer, token_to_claim)
        if not peer_id:
            print(
                f"Failed to claim session token. Peer {packet.peer_id} does not exist.")
            return

        print(f"{peer.debug_name} claimed token.")

        peer.set_state(AuthenticatedState(peer))

        payloads = ClaimTokenResp(peer_id=peer.id)
        resp = Packet[ClaimTokenResp](
            action=Action.ClaimTokenResp,
            peer_id=1,
            session_token="",
            payloads=payloads
        )

        await peer.send_packet(resp)

        welcome_message = f"Welcome to the server, {peer.user.name}!"
        await send_server_message(welcome_message, filter=[peer])

        online_alert_message = f"{peer.user.name} is online."
        await send_server_message(online_alert_message, filter=[peer], exclude=True)


    @staticmethod
    async def handle_chat_message(
            sender: Peer,
            packet: Packet[ChatMessage]
    ) -> None:
        print("Got chat packet.")

        peer_manager = get_peer_manager()

        chat_message = packet.payloads.message
        if not chat_message:
            print("Chat has no message!")
            return

        chat_payloads = ChatMessage(
            sender=sender.user.name,
            message=chat_message
        )

        out_packet = Packet[ChatMessage](
            action=Action.ChatMessage,
            peer_id=1,
            session_token="",
            payloads=chat_payloads
        )

        for peer in peer_manager.active_peers.values():
            print(f"Forwarding chat to {peer.debug_name}")
            await peer.send_packet(out_packet)


class UnauthenticatedState(ConnectionState):
    ALLOWED_ACTIONS: dict[Action, Callable] = {
        Action.ClaimTokenReq: ConnectionState.handle_claim_token,
    }

    async def handle_packet(self, packet):
        handler_func = self.ALLOWED_ACTIONS.get(packet.action)
        if not handler_func:
            message = f"Cannot perform action {packet.action}."
            reason = "Unauthorized."
            await send_deny(self.peer, message, reason)
            return

        await handler_func(self.peer, packet)


class AuthenticatedState(ConnectionState):
    ALLOWED_ACTIONS: dict[Action, Callable] = {
        Action.ChatMessage: ConnectionState.handle_chat_message,
    }

    async def handle_packet(self, packet):
        if packet.session_token != self.peer.session.token:
            print(f"{self.peer.debug_name} provided a bad session token.")
            return

        handler_func = self.ALLOWED_ACTIONS.get(packet.action)
        if not handler_func:
            message = f"Cannot perform action {packet.action}."
            reason = "Unauthorized."
            await send_deny(self.peer, message, reason)
            return

        print(handler_func)
        await handler_func(self.peer, packet)


async def send_server_message(
        message: str,
        filter: list[Peer] = [],
        exclude=False
) -> None:
    peer_manager = get_peer_manager()

    if filter and exclude:
        targets = [peer for peer in peer_manager.active_peers.values()
            if peer not in filter]
    elif filter:
        targets = filter
    else:
        targets = peer_manager.active_peers.values()

    print(
        f"Sending server message to {len(targets)} of {len(peer_manager.active_peers)} peers. Message: {message}")

    packet = Packet[ServerMessage](
        action=Action.ServerMessage,
        peer_id=1,
        session_token = "",
        payloads = ServerMessage(message=message)
    )

    for peer in targets:
        await peer.send_packet(packet)


async def send_deny(peer: Peer, message: str, reason: str) -> None:
    payloads = Deny(
        message=message,
        reason=reason
    )

    deny_packet = Packet[Deny](
        action=Action.Deny,
        peer_id=1,
        session_token="",
        payloads=payloads
    )

    await peer.send_packet(deny_packet)


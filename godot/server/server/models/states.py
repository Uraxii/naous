from abc import ABC, abstractmethod

from dependencies import get_peer_manager
from models.peer import Peer
from .packets import Action, ChatPacket, ChatPayloads, ClaimTokenPacket, ClaimTokenPayloads, DenyPacket, DenyPayloads, Packet


class ConnectionState(ABC):
    def __init__(self, peer: Peer):
        self.peer_manager = get_peer_manager()
        self.peer = peer


    @abstractmethod
    async def handle_packet(self, packet: Packet) -> None:
        pass


class UnauthenticatedState(ConnectionState):
    async def handle_packet(self, packet):
        if packet.action != Action.ClaimToken:
            payloads = DenyPayloads(
                message=f"Cannot perform action {packet.action}.",
                reason="Not authorized."
            )

            deny_packet = DenyPacket(payloads=payloads)
            await self.peer.send_packet(deny_packet)
            return

        await handle_claim_token(self.peer, packet)


class AuthenticatedState(ConnectionState):
    async def handle_packet(self, packet):
        if packet.session_token != self.peer.session.token:
            print(f"{self.peer.debug_name} gave a bad session token.")
            return

        action = packet.action

        if action == Action.ChatMessage:
            await handle_chat_message(self.peer, packet)


async def handle_claim_token(peer: Peer, packet: Packet) -> None:
    print("Got claim token packet.")

    peer_manager = get_peer_manager()
    peer_id = peer_manager.activate_peer(peer, packet.session_token)
    if not peer_id:
        print(f"Failed to claim session token. Peer {packet.peer_id} does not exist.")
        return

    print(f"{peer.debug_name} claimed token.")

    peer.set_state(AuthenticatedState(peer))

    payloads = ClaimTokenPayloads(peer_id=peer.id)
    claim_token_packet = ClaimTokenPacket(payloads=payloads)
    await peer.send_packet(claim_token_packet)

    welcome_message = f"Welcome to the server, {peer.user.name}!"
    await send_server_message(welcome_message, filter=[peer])

    online_alert_message = f"{peer.user.name} is online."
    await send_server_message(online_alert_message, filter=[peer], exclude=True)


async def handle_chat_message(sender: Peer, packet: Packet) -> None:
    #print("Got chat packet.")

    peer_manager = get_peer_manager()

    chat_message = packet.payloads.get("message")
    if not chat_message:
        print("Chat has no message!")
        return

    chat_payloads = ChatPayloads(
        sender = sender.user.name,
        message = chat_message
    )

    out_packet = ChatPacket(payloads=chat_payloads)

    for peer in peer_manager.active_peers.values():
        print(f"Forwarding chat to {peer.debug_name}")
        await peer.send_packet(out_packet)


async def send_server_message(
        message: str,
        filter: list[Peer] = [],
        exclude=False
):
    peer_manager = get_peer_manager()

    if filter and exclude:
        targets = [peer for peer in peer_manager.active_peers.values()
            if peer not in filter]
    elif filter:
        targets = filter
    else:
        targets = peer_manager.active_peers.values()

    print(f"Sending server message to {len(targets)} of {len(peer_manager.active_peers)} peers. Message: {message}")

    packet = Packet(
        action=Action.ServerMessage,
        peer_id=1,
        session_token = "",
        payloads = { "message": f"{message}" }
    )

    for peer in targets:
        await peer.send_packet(packet)


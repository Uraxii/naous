import json
from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect

from dependencies import get_peer_manager
from models.states import UnauthenticatedState
from models.peer import Peer
from models.packets import Action, Packet, ChatPacket, ChatPayloads
from services.peer_manager import PeerManager


router = APIRouter()


@router.websocket("/ws")
async def websocket_endpoint(
        websocket: WebSocket,
        peer_manager: PeerManager = Depends(get_peer_manager)
):
    await websocket.accept()
    peer = peer_manager.create_peer(websocket)

    if not peer:
        print("Failed to create peer.")

        await websocket.close()
        return

    peer.current_state = UnauthenticatedState(peer)

    try:
        while True:
            json_str = await peer.socket.receive_text()
            print(f"Got Packet:{json_str}")
            obj_dict = json.loads(json_str)
            packet = Packet(**obj_dict)
            await peer.handle_packet(packet)
            #await route_packet(peer, packet)
    except WebSocketDisconnect:
        print("Peer disconnected.")
    except Exception as e:
        print(f"An error occurred: {e}")

    if peer.id:
        peer_manager.deactivate_peer(peer.id)


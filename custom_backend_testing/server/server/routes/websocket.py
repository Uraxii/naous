import json
from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect

from dependencies import get_peer_manager
from models.states import UnauthenticatedState
from services.peer_manager import PeerManager
from services.packet_factory import PacketFactory


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
            packet_dict: dict = json.loads(json_str)
            packet = PacketFactory.create_packet(packet_dict)
            #print(f"Packet:{packet}")
            await peer.current_state.handle_packet(packet)
    except WebSocketDisconnect:
        print("Peer disconnected.")
    except Exception as e:
        print(f"An error occurred: {e}")

    if peer.id:
        peer_manager.deactivate_peer(peer.id)


from datetime import timedelta
from fastapi import APIRouter, Depends, status
from fastapi.exceptions import HTTPException

from dependencies import get_peer_manager, get_db
from models.responses import *
from models.post import *
from models.game import *
from models.peer import InactiveSession, Session
from services.peer_manager import PeerManager


router = APIRouter()


@router.post("/login", response_model=LoginResponse)
async def login(
        data: LoginPost,
        peer_manager: PeerManager=Depends(get_peer_manager)
)-> LoginResponse:
    user = User(id=data.user_id, name=data.user_id, roles=['chat'])
    session = Session(timedelta(minutes=60))
    inactive_session = InactiveSession(session, user)
    peer_manager.add_inactive_session(inactive_session)
    return LoginResponse(session_token=session.token)


@router.post("/logout", response_model=LogoutResponse)
async def logout(
        data: LogoutPost,
        peer_manager: PeerManager=Depends(get_peer_manager)
) -> LogoutResponse:
    peer = peer_manager.get_peer(data.peer_id)
    if not peer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    if not peer.is_valid_token(data.session_token):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    peer_manager.deactivate_peer(peer.id)
    await peer.socket.close()

    return LogoutResponse(message="Good-bye!")


@router.post("/character/{user_id}")
async def post_character(
        user_id: str,
        data: Character,
        db=get_db
) -> Character:
    return data

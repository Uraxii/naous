from pydantic import BaseModel


class LoginPost(BaseModel):
    user_id: str
    secret: str


class LogoutPost(BaseModel):
    peer_id: int
    session_token: str


class CharacterDataPost(BaseModel):
    name: str

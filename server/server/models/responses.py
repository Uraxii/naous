from pydantic import BaseModel


class LoginResponse(BaseModel):
    session_token: str


class LogoutResponse(BaseModel):
    message: str


class CharacterDataPostResponse(BaseModel):
    name: str

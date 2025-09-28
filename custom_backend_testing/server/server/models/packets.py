import enum
from typing import Generic, Optional, Type, TypeVar
from pydantic import BaseModel, Field

TPayloads = TypeVar('TPayloads', bound='Payloads')


class Action(str, enum.Enum):
    Ok = "Ok"
    Deny = "Deny"
    Malformed = "Malformed"
    Disconnect = "Disconnect"
    ClaimTokenReq = "ClaimTokenReq"
    ClaimTokenResp = "ClaimTokenResp"
    Register = "Register"
    ChatMessage = "ChatMessage"
    ServerMessage = "ServerMessage"
    ModelDelta = "ModelDelta"
    Target = "Target"


class Packet(BaseModel, Generic[TPayloads]):
    action: Action = Field(description="The type of message.")
    peer_id: Optional[int] = Field(description="Which peer is sending this packet.")
    session_token: Optional[str] = Field(
        description="The session token used to authenticate the message.")

    payloads: TPayloads = Field(description="The data used for the message.")


class Payloads(BaseModel):
    pass


class Deny(Payloads):
    message: str
    reason: str


class Malformed(Payloads):
    details: str = "This packet was malformed."


class ClaimTokenReq(Payloads):
    session_token_to_claim: str


class ClaimTokenResp(Payloads):
    peer_id: int


class ServerMessage(Payloads):
    message: str


class ChatMessage(Payloads):
    sender: str
    message: str


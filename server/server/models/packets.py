import enum
from pydantic import BaseModel, Field


class Action(str, enum.Enum):
    Ok = "Ok"
    Deny = "Deny"
    Malformed = "Malformed"
    Disconnect = "Disconnect"
    ClaimToken = "ClaimToken"
    Register = "Register"
    ChatMessage = "ChatMessage"
    ServerMessage = "ServerMessage"
    ModelDelta = "ModelDelta"
    Target = "Target"


class Packet(BaseModel):
    action: Action = Field(description="The type of message.")
    peer_id: int = Field(description="Which peer sent the packet.")
    session_token: str = Field(
        description="The session token used to authenticate the message.")

    payloads: dict = Field(description="The data used for the message.")


class DenyPayloads(BaseModel):
    message: str
    reason: str


class DenyPacket(BaseModel):
    action: Action = Action.Deny
    payloads: DenyPayloads


class MalformedPacket(BaseModel):
    details: str = "This packet was malformed."


class ClaimTokenPayloads(BaseModel):
    peer_id: int


class ClaimTokenPacket(BaseModel):
    action: Action = Action.ClaimToken
    payloads: ClaimTokenPayloads


class ChatPayloads(BaseModel):
    sender: str
    message: str


class ChatPacket(BaseModel):
    action: Action = Action.ChatMessage
    payloads: ChatPayloads


class TransformPacket(BaseModel):
    character: str
    pos_x: float
    pos_y: float
    pos_z: float
    rot_x: float
    rot_y: float
    rot_z: float


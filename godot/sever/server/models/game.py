from pydantic import BaseModel

from .vectors import Vector3


class Transform(BaseModel):
    position:   Vector3 = Vector3.ZERO()
    rotation:   Vector3 = Vector3(x=1,y=1,z=1)
    scale:      Vector3 = Vector3(x=1,y=1,z=1)


class User(BaseModel):
    id: str
    name: str
    roles: list[str]

    def has_role(self, role: str) -> bool:
        return role in self.roles


class Character(BaseModel):
    id: str
    name: str
    user: User
    group: "Group"
    instance: "Instance"
    zone: str
    transform_queue: list[Transform]


    @property
    def transform(self) -> Transform:
        return self.transform_queue[-1]


class Group(BaseModel):
    id: int = 0
    members: list[Character] = []


class Instance(BaseModel):
    id: int = 0
    members: list[Character] = []


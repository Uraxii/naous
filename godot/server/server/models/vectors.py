from pydantic import BaseModel


class Vector3(BaseModel):
    x: float
    y: float
    z: float


    @classmethod
    def ZERO(cls) -> "Vector3":
        return cls(x=0.0, y=0.0, z=0.0)


    def __repr__(self) -> str:
        return f"Vector3(x={self.x}, y={self.y}, z={self.z})"

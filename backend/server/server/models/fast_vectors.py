import numpy as np


class Vector3(np.ndarray):
    @classmethod
    def ZERO(cls):
        """Returns a new 4 vector with all values set to zero."""
        return cls(0, 0, 0)


    def __new__(cls, x: float, y: float, z: float):
        obj = np.asarray([x, y, z], dtype=np.float64).view(cls)
        if obj.shape != (3,):
            raise ValueError("Input array must be a 3-demensional vector.")

        return obj

    @property
    def x(self) -> float:
        return self[0]

    @property
    def y(self) -> float:
        return self[1]

    @property
    def z(self) -> float:
        return self[2]



# We *probably* wont need this, but in this context, time means the tick.
class Vector4(np.ndarray):
    @classmethod
    def ZERO(cls):
        """Returns a new 4 vector with all values set to zero."""
        return cls(np.zeros(4, dtype=np.float64))


    def __new__(cls, input_array: np.ndarray):
        obj = np.asarray(input_array).view(cls)
        if obj.shape != (4,):
            raise ValueError("Input array must be a 4-demensional vector.")

        return obj

    @property
    def x(self) -> float:
        return self[0]

    @property
    def y(self) -> float:
        return self[1]

    @property
    def z(self) -> float:
        return self[2]

    @property
    def t(self) -> float:
        return self[3]


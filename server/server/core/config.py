import warnings
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    warnings.filterwarnings(
        "ignore", message="(trapped) error reading bcrypt version")

    # Server settings
    HOST: str = "0.0.0.0"
    PORT: int = 8080
    DEBUG: bool = True

    # Database
    DATABASE_PORT: int = 27017
    DATABASE_URI: str = f"localhost"
    DATABASE_NAME: str ="naous"

    ADMIN_USERNAME: str = "admin"
    ADMIN_PASSWORD: str = "nimda"

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()


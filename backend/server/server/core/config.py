import warnings
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    warnings.filterwarnings("ignore", message="(trapped) error reading bcrypt version")

    # Server settings
    HOST: str = "0.0.0.0"
    PORT: int = 8080
    DEBUG: bool = True

    # Security
    SECRET_KEY: str = "your-secret-key-change-this-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # Database
    DATABASE_URL: str = ""

    ADMIN_USERNAME: str = "admin"
    ADMIN_PASSWORD: str = "nimda"

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()

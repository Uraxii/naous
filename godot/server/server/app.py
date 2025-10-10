from contextlib import asynccontextmanager
from datetime import datetime
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from typing import AsyncGenerator

from routes import rest, websocket
from core.config import settings
from dependencies import get_peer_manager


app = FastAPI(
    title="Naous Server",
    description="Backend API server for Naous.",
    version="0.0.1",
)

# TODO: Harden this!
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(
    rest.router,
    prefix = "/api",
    tags = ["routes", "http"]
)

app.include_router(
    websocket.router,
    prefix = "/api",
    tags = ["routes", "ws"]
)


@app.get("/")
async def root():
    return {
        "app": app.title,
        "description": app.description, 
        "version": app.version
    }


@app.get("/favicon.ico")
async def favicon():
    return {}


@app.get("/health")
async def health_check():
    """
    Returns the server's current status and uptime.
    This is useful for load balancers and container orchestrators.
    """

    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "details": "Server is running and operational."
    }


@app.get("/version")
async def version():
    """
    Return version number of the this API.
    """

    return {
        "version": "0.0.1"
    }


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    # Things to do at startup

    peer_manager = get_peer_manager()
    await peer_manager.start_removing_expired_peers_async(interval_sec=600.0)

    yield

    # Things to do at shutdown


def main() -> None:
    import uvicorn

    uvicorn.run(
        "app:app",
        host = settings.HOST,
        port = settings.PORT,
        reload = settings.DEBUG,
        log_level = "info"
    )


if __name__ == "__main__":
    main()


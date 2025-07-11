#!/bin/bash
echo "🧹 Stopping existing containers..."
docker-compose down

FORCE_REBUILD=${1:-false}

if [ "$FORCE_REBUILD" = "force" ] || [ "$1" = "--force" ]; then
    echo "🗑️  Removing existing images (forced rebuild)..."
    docker-compose down --rmi all
    BUILD_FLAGS="--no-cache"
else
    BUILD_FLAGS=""
fi

echo "🏗️  Rebuilding images with cache bust..."
docker-compose build $BUILD_FLAGS

echo "✅ Build complete!"
echo ""
echo "To run the services manually:"
echo "  docker-compose up"
echo ""
echo "To force a complete rebuild next time:"
echo "  ./build.shd --force"
echo ""
echo "Admin dashboard will be available at: http://localhost:5001"
echo "Server WebSocket endpoint: ws://localhost:5000/ws"

echo "🚀 Starting services with docker-compose..."
docker-compose up


from fastapi import APIRouter
from app.api.v1.endpoints import auth, users, streams

api_router = APIRouter()

# Include routers
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])

# Uncomment these when the modules are implemented
# api_router.include_router(users.router, prefix="/users", tags=["Users"])
# api_router.include_router(streams.router, prefix="/streams", tags=["Streams"])

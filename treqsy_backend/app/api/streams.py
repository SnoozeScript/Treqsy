from fastapi import APIRouter, HTTPException, Depends
from datetime import datetime
from typing import List
from motor.motor_asyncio import AsyncIOMotorClient
import os

from app.models.stream import StreamSession
from app.core.dependencies import RoleChecker
from app.models.user import Role, User

# This dependency ensures only users with 'host' or 'master_admin' roles can access endpoints.
host_access = Depends(RoleChecker(allowed_roles=[Role.HOST, Role.MASTER_ADMIN]))

router = APIRouter(prefix="/streams", tags=["streams"])

MONGO_URI = os.getenv("MONGODB_URI", "mongodb://localhost:27017")
client = AsyncIOMotorClient(MONGO_URI)
db = client["treqsy"]
streams_collection = db["streams"]


@router.post("/start", response_model=StreamSession, dependencies=[host_access])
async def start_stream(title: str, user: dict = host_access):
    # The user's info (including email) is now securely taken from the JWT payload
    # provided by the 'host_access' dependency.
    host_email = user.get("sub")
    session = StreamSession(host_email=host_email, title=title)
    
    session_dict = session.dict(by_alias=True)
    if session_dict.get("_id") is None:
        session_dict.pop("_id")

    await streams_collection.insert_one(session_dict)
    return session

@router.post("/{stream_id}/end", response_model=StreamSession)
async def end_stream(stream_id: str):
    session = await streams_collection.find_one_and_update(
        {"_id": stream_id, "is_active": True},
        {"$set": {"is_active": False, "end_time": datetime.utcnow()}},
        return_document=True
    )
    if not session:
        raise HTTPException(status_code=404, detail="Active stream not found")
    return session

@router.get("/active", response_model=List[StreamSession])
async def get_active_streams():
    streams = await streams_collection.find({"is_active": True}).to_list(100)
    return streams 
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
import uuid

class StreamSession(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()), alias="_id")
    host_email: str
    title: Optional[str] = None
    start_time: datetime = Field(default_factory=datetime.utcnow)
    end_time: Optional[datetime] = None
    is_active: bool = True 
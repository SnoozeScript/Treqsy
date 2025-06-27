from enum import Enum
from pydantic import BaseModel, EmailStr, Field
from typing import Optional

class Role(str, Enum):
    MASTER_ADMIN = "master_admin"
    ADMIN = "admin"
    HOST = "host"
    USER = "user"

class User(BaseModel):
    id: Optional[str] = Field(alias="_id", default=None)
    email: EmailStr
    hashed_password: str
    role: Role = Role.USER
    is_active: bool = True
    is_vip: bool = False
    coins: int = 0 
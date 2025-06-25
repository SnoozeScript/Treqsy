from datetime import datetime
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, EmailStr, Field, validator
from bson import ObjectId
from app.core.config import settings

class PyObjectId(ObjectId):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid ObjectId")
        return ObjectId(v)

    @classmethod
    def __modify_schema__(cls, field_schema):
        field_schema.update(type="string")

class UserBase(BaseModel):
    username: Optional[str] = None
    email: Optional[EmailStr] = None
    phone_number: Optional[str] = None
    full_name: Optional[str] = None
    is_active: bool = True
    is_verified: bool = False
    role: str = "user"  # user, host, agent, agency, admin, super_admin
    profile_picture: Optional[str] = None
    bio: Optional[str] = None
    date_of_birth: Optional[datetime] = None
    gender: Optional[str] = None
    country: Optional[str] = None
    language: str = "en"
    timezone: str = "UTC"
    last_login: Optional[datetime] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    metadata: Dict[str, Any] = {}

    class Config:
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "username": "johndoe",
                "email": "johndoe@example.com",
                "full_name": "John Doe",
                "is_active": True,
                "role": "user"
            }
        }

class UserCreate(UserBase):
    username: str
    password: str
    email: Optional[EmailStr] = None
    phone_number: Optional[str] = None

    @validator('username')
    def username_alphanumeric(cls, v):
        import re
        if not re.match(r'^[a-zA-Z0-9_]+$', v):
            raise ValueError('Username must be alphanumeric with underscores')
        return v

    @validator('password')
    def password_complexity(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v

class UserUpdate(UserBase):
    password: Optional[str] = None
    email: Optional[EmailStr] = None
    phone_number: Optional[str] = None

    @validator('password')
    def password_complexity(cls, v):
        if v is not None and len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v

class UserInDB(UserBase):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    hashed_password: str
    email_verified: bool = False
    phone_verified: bool = False
    kyc_verified: bool = False
    kyc_status: str = "not_submitted"  # not_submitted, pending, approved, rejected
    kyc_details: Dict[str, Any] = {}
    login_history: List[Dict[str, Any]] = []
    devices: List[Dict[str, Any]] = []
    settings: Dict[str, Any] = {}
    social_profiles: Dict[str, Any] = {}
    permissions: List[str] = []
    status: str = "active"  # active, suspended, banned, deleted
    deleted_at: Optional[datetime] = None

    class Config:
        allow_population_by_field_name = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "_id": "507f1f77bcf86cd799439011",
                "username": "johndoe",
                "email": "johndoe@example.com",
                "full_name": "John Doe",
                "is_active": True,
                "role": "user",
                "created_at": "2023-01-01T00:00:00",
                "updated_at": "2023-01-01T00:00:00"
            }
        }

class User(UserInDB):
    pass

class UserInResponse(BaseModel):
    user: User
    access_token: str
    token_type: str = "bearer"

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None
    user_id: Optional[str] = None
    scopes: List[str] = []

class UserInLogin(BaseModel):
    login: str  # Can be email or username
    password: str
    remember_me: bool = False

class UserInSignup(UserCreate):
    confirm_password: str
    terms_accepted: bool = False

    @validator('confirm_password')
    def passwords_match(cls, v, values, **kwargs):
        if 'password' in values and v != values['password']:
            raise ValueError('Passwords do not match')
        return v

    @validator('terms_accepted')
    def terms_must_be_accepted(cls, v):
        if not v:
            raise ValueError('You must accept the terms and conditions')
        return v

class PasswordResetRequest(BaseModel):
    email: EmailStr

class PasswordResetConfirm(BaseModel):
    token: str
    new_password: str
    confirm_password: str

    @validator('confirm_password')
    def passwords_match(cls, v, values, **kwargs):
        if 'new_password' in values and v != values['new_password']:
            raise ValueError('Passwords do not match')
        return v

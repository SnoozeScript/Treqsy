from pydantic import BaseModel, EmailStr
from app.models.user import Role

class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    role: Role = Role.USER 
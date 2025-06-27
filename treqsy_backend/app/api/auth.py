from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordRequestForm
from motor.motor_asyncio import AsyncIOMotorClient
from app.models.user import User, Role
from app.models.requests import RegisterRequest
from app.core.security import get_password_hash, verify_password, create_access_token
import os
from dotenv import load_dotenv

load_dotenv()

router = APIRouter(prefix="/auth", tags=["auth"])

MONGO_URI = os.getenv("MONGODB_URI", "mongodb://localhost:27017")
client = AsyncIOMotorClient(MONGO_URI)
db = client["treqsy"]
users_collection = db["users"]

# Registration endpoint: expects JSON body, always hashes password, stores correct fields
@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(request: RegisterRequest):
    try:
        existing = await users_collection.find_one({"email": request.email})
        if existing:
            raise HTTPException(status_code=400, detail="Email already registered")
        hashed_password = get_password_hash(request.password)
        user_data = {
            "email": request.email,
            "hashed_password": hashed_password,
            "role": request.role,
            "is_active": True,
        }
        user = User(**user_data)
        user_dict = user.dict(by_alias=True)
        if user_dict.get("_id") is None:
            user_dict.pop("_id", None) # Use pop with default to avoid key error
        await users_collection.insert_one(user_dict)
        return {"msg": "User registered successfully"}
    except Exception as e:
        print("Registration error:", str(e))
        raise

# Login endpoint: expects form data (username and password), looks up user by email, verifies password hash
@router.post("/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    print("Login attempt:", form_data.username, form_data.password)
    user_data = await users_collection.find_one({"email": form_data.username})
    print("User from DB:", user_data)
    if not user_data or not verify_password(form_data.password, user_data["hashed_password"]):
        print("Login failed: invalid credentials or password mismatch")
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token_data = {
        "sub": str(user_data["_id"]),
        "role": user_data.get("role", "user"),
        "email": user_data["email"]
    }
    token = create_access_token(token_data)
    print("Login successful, token issued")
    return {"access_token": token, "token_type": "bearer", "role": token_data["role"]} 
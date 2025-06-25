from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from motor.motor_asyncio import AsyncIOMotorDatabase
from bson import ObjectId
import secrets
import string

from app.core.config import settings
from app.models.user import UserInDB, User, TokenData, UserCreate, UserInLogin, UserInSignup
from app.db.base import db
from app.core.security import verify_password, get_password_hash

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{settings.API_V1_STR}/auth/login")

class AuthService:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.db = db
    
    async def authenticate_user(self, login: str, password: str) -> Optional[UserInDB]:
        """Authenticate a user with email/username and password."""
        # Try to find user by email or username
        user_dict = await self.db.users.find_one({
            "$or": [
                {"email": login.lower()},
                {"username": login.lower()}
            ]
        })
        
        if not user_dict:
            return None
            
        user = UserInDB(**user_dict)
        
        if not user.is_active:
            return None
            
        if not verify_password(password, user.hashed_password):
            return None
            
        return user
    
    async def create_user(self, user_data: UserCreate) -> UserInDB:
        """Create a new user."""
        # Check if username or email already exists
        existing_user = await self.db.users.find_one({
            "$or": [
                {"email": user_data.email.lower() if user_data.email else None},
                {"username": user_data.username.lower()}
            ]
        })
        
        if existing_user:
            if existing_user.get("email") == user_data.email:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Email already registered"
                )
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already taken"
            )
        
        # Hash the password
        hashed_password = get_password_hash(user_data.password)
        
        # Create user document
        user_dict = user_data.dict(exclude={"password"})
        user_dict["hashed_password"] = hashed_password
        user_dict["created_at"] = datetime.utcnow()
        user_dict["updated_at"] = datetime.utcnow()
        user_dict["is_active"] = True
        user_dict["is_verified"] = False
        
        # Insert user into database
        result = await self.db.users.insert_one(user_dict)
        
        # Get the created user
        created_user = await self.db.users.find_one({"_id": result.inserted_id})
        
        return UserInDB(**created_user)
    
    def create_access_token(self, data: dict, expires_delta: Optional[timedelta] = None) -> str:
        """Create a JWT access token."""
        to_encode = data.copy()
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
            
        to_encode.update({"exp": expire, "type": "access"})
        encoded_jwt = jwt.encode(
            to_encode, 
            settings.SECRET_KEY, 
            algorithm=settings.ALGORITHM
        )
        return encoded_jwt
    
    def create_refresh_token(self, data: dict) -> str:
        """Create a refresh token."""
        to_encode = data.copy()
        expire = datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
        to_encode.update({"exp": expire, "type": "refresh"})
        encoded_jwt = jwt.encode(
            to_encode, 
            settings.REFRESH_SECRET_KEY, 
            algorithm=settings.ALGORITHM
        )
        return encoded_jwt
    
    async def get_current_user(self, token: str = Depends(oauth2_scheme)) -> UserInDB:
        """Get the current authenticated user from the JWT token."""
        credentials_exception = HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
        
        try:
            payload = jwt.decode(
                token, 
                settings.SECRET_KEY, 
                algorithms=[settings.ALGORITHM]
            )
            
            # Check token type
            if payload.get("type") != "access":
                raise credentials_exception
                
            user_id = payload.get("sub")
            if user_id is None:
                raise credentials_exception
                
            token_data = TokenData(user_id=user_id)
            
        except JWTError:
            raise credentials_exception
            
        user = await self.db.users.find_one({"_id": ObjectId(token_data.user_id)})
        if user is None:
            raise credentials_exception
            
        return UserInDB(**user)
    
    async def get_refresh_user(self, token: str) -> UserInDB:
        """Get user from refresh token."""
        try:
            payload = jwt.decode(
                token, 
                settings.REFRESH_SECRET_KEY, 
                algorithms=[settings.ALGORITHM]
            )
            
            # Check token type
            if payload.get("type") != "refresh":
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid token type"
                )
                
            user_id = payload.get("sub")
            if user_id is None:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid token"
                )
                
            user = await self.db.users.find_one({"_id": ObjectId(user_id)})
            if user is None:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User not found"
                )
                
            return UserInDB(**user)
            
        except JWTError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )
    
    async def generate_reset_token(self, email: str) -> str:
        """Generate a password reset token."""
        user = await self.db.users.find_one({"email": email.lower()})
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User with this email does not exist"
            )
            
        # Create a reset token that expires in 1 hour
        reset_token = self.create_access_token(
            data={"sub": str(user["_id"])},
            expires_delta=timedelta(hours=1)
        )
        
        return reset_token
    
    async def reset_password(self, token: str, new_password: str) -> bool:
        """Reset user password using a reset token."""
        try:
            payload = jwt.decode(
                token, 
                settings.SECRET_KEY, 
                algorithms=[settings.ALGORITHM]
            )
            
            user_id = payload.get("sub")
            if user_id is None:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid token"
                )
                
            # Update user password
            hashed_password = get_password_hash(new_password)
            result = await self.db.users.update_one(
                {"_id": ObjectId(user_id)},
                {"$set": {"hashed_password": hashed_password}}
            )
            
            if result.matched_count == 0:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User not found"
                )
                
            return True
            
        except JWTError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or expired token"
            )
    
    async def verify_email(self, token: str) -> bool:
        """Verify user email using a verification token."""
        try:
            payload = jwt.decode(
                token, 
                settings.SECRET_KEY, 
                algorithms=[settings.ALGORITHM]
            )
            
            user_id = payload.get("sub")
            if user_id is None:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid token"
                )
                
            # Update user email verification status
            result = await self.db.users.update_one(
                {"_id": ObjectId(user_id)},
                {
                    "$set": {
                        "is_verified": True,
                        "email_verified": True,
                        "updated_at": datetime.utcnow()
                    }
                }
            )
            
            if result.matched_count == 0:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User not found"
                )
                
            return True
            
        except JWTError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or expired token"
            )
    
    async def create_email_verification_token(self, user_id: str) -> str:
        """Create an email verification token."""
        return self.create_access_token(
            data={"sub": user_id},
            expires_delta=timedelta(days=7)  # 7 days to verify email
        )

# Create auth service instance
auth_service = AuthService(db)

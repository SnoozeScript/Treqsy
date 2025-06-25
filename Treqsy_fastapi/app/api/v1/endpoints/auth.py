from fastapi import APIRouter, Depends, HTTPException, status, Body
from fastapi.security import OAuth2PasswordRequestForm
from typing import Any

from app.models.user import (
    User, UserInDB, UserCreate, UserInLogin, UserInSignup,
    UserInResponse, Token, PasswordResetRequest, PasswordResetConfirm
)
from app.services.auth import auth_service
from app.core.security import get_current_user

router = APIRouter()

@router.post("/login", response_model=UserInResponse)
async def login(login_data: UserInLogin):
    """
    OAuth2 compatible token login, get an access token for future requests
    """
    user = await auth_service.authenticate_user(login_data.login, login_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect email/username or password"
        )
    
    access_token = auth_service.create_access_token(
        data={"sub": str(user.id)}
    )
    
    refresh_token = auth_service.create_refresh_token(
        data={"sub": str(user.id)}
    )
    
    return {
        "user": user,
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post("/login/access-token", response_model=Token)
async def login_access_token(
    form_data: OAuth2PasswordRequestForm = Depends()
):
    """
    OAuth2 compatible token login, get an access token for future requests
    """
    user = await auth_service.authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect email or password"
        )
    elif not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    
    access_token = auth_service.create_access_token(
        data={"sub": str(user.id)}
    )
    
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/signup", response_model=UserInResponse, status_code=status.HTTP_201_CREATED)
async def create_user(user_in: UserInSignup):
    """
    Create new user.
    """
    # Check if passwords match
    if user_in.password != user_in.confirm_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Passwords do not match"
        )
    
    # Create user data
    user_data = UserCreate(
        username=user_in.username,
        email=user_in.email,
        password=user_in.password,
        full_name=user_in.full_name,
    )
    
    # Create user
    user = await auth_service.create_user(user_data)
    
    # Generate access token
    access_token = auth_service.create_access_token(
        data={"sub": str(user.id)}
    )
    
    refresh_token = auth_service.create_refresh_token(
        data={"sub": str(user.id)}
    )
    
    # Create user response
    user_dict = user.dict()
    user_dict["id"] = str(user_dict["id"])
    
    return {
        "user": user_dict,
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post("/refresh-token", response_model=Token)
async def refresh_token(refresh_token: str = Body(...)):
    """
    Refresh access token using refresh token
    """
    user = await auth_service.get_refresh_user(refresh_token)
    
    # Generate new access token
    access_token = auth_service.create_access_token(
        data={"sub": str(user.id)}
    )
    
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/password-recovery/{email}")
async def recover_password(email: str):
    """
    Password Recovery
    """
    try:
        reset_token = await auth_service.generate_reset_token(email)
        # In a real app, you would send the reset token to the user's email
        # For now, we'll just return it
        return {"message": "Password recovery email sent", "reset_token": reset_token}
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while processing your request"
        )

@router.post("/reset-password/")
async def reset_password(
    token: str = Body(...),
    new_password: str = Body(...),
    confirm_password: str = Body(...),
):
    """
    Reset password
    """
    if new_password != confirm_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Passwords do not match"
        )
    
    try:
        await auth_service.reset_password(token, new_password)
        return {"message": "Password updated successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while resetting your password"
        )

@router.post("/verify-email/{token}")
async def verify_email(token: str):
    """
    Verify email
    """
    try:
        await auth_service.verify_email(token)
        return {"message": "Email verified successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while verifying your email"
        )

@router.get("/test-token", response_model=User)
async def test_token(current_user: UserInDB = Depends(get_current_user)):
    """
    Test access token
    """
    return current_user

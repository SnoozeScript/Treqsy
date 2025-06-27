from fastapi import APIRouter, Depends
from app.models.user import User
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/me", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_user)):
    # The get_current_user dependency already provides the user model.
    # In a real application you might re-fetch from DB to ensure data is fresh.
    return current_user 
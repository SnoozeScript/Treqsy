from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class CoinTransaction(BaseModel):
    user_id: str
    type: str  # purchase, gift, payout, etc.
    amount: int
    timestamp: datetime
    details: Optional[str] = None 
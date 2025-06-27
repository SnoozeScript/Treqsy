from fastapi import APIRouter, Depends, HTTPException, Body
from app.models.user import Role, User
from app.core.dependencies import RoleChecker
from motor.motor_asyncio import AsyncIOMotorClient
import os
from datetime import datetime
from app.models.coin_transaction import CoinTransaction

router = APIRouter(prefix="/admin", tags=["admin"])

MONGO_URI = os.getenv("MONGODB_URI", "mongodb://localhost:27017")
client = AsyncIOMotorClient(MONGO_URI)
db = client["treqsy"]
users_collection = db["users"]
settings_collection = db["settings"]
coin_transactions = db["coin_transactions"]
payout_requests = db["payout_requests"]

master_admin_only = RoleChecker([Role.MASTER_ADMIN])
admin_or_master = RoleChecker([Role.ADMIN, Role.MASTER_ADMIN])

# --- User Management ---
@router.get("/users", dependencies=[Depends(admin_or_master)])
async def list_users(current_user: User = Depends(admin_or_master)):
    # Master admin sees all, admin sees only their region (dummy: all for now)
    users = await users_collection.find().to_list(100)
    return users

@router.post("/users/{user_id}/role", dependencies=[Depends(master_admin_only)])
async def change_user_role(user_id: str, new_role: Role = Body(...)):
    result = await users_collection.update_one({"_id": user_id}, {"$set": {"role": new_role}})
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="User not found or role unchanged")
    return {"msg": "Role updated"}

@router.post("/users/{user_id}/activate", dependencies=[Depends(master_admin_only)])
async def activate_user(user_id: str, active: bool = Body(...)):
    result = await users_collection.update_one({"_id": user_id}, {"$set": {"is_active": active}})
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="User not found or status unchanged")
    return {"msg": "User status updated"}

@router.post("/users/{user_id}/vip", dependencies=[Depends(master_admin_only)])
async def toggle_vip_status(user_id: str, is_vip: bool = Body(...)):
    result = await users_collection.update_one(
        {"_id": user_id},
        {"$set": {"is_vip": is_vip}}
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="User not found or VIP status unchanged")
    return {"msg": "VIP status updated"}

# --- App Settings ---
@router.get("/settings/app_name", dependencies=[Depends(master_admin_only)])
async def get_app_name():
    doc = await settings_collection.find_one({"key": "app_name"})
    return {"app_name": doc["value"] if doc else "Treqsy"}

@router.post("/settings/app_name", dependencies=[Depends(master_admin_only)])
async def set_app_name(name: str = Body(...)):
    await settings_collection.update_one({"key": "app_name"}, {"$set": {"value": name}}, upsert=True)
    return {"msg": "App name updated"}

# --- Wallet Analytics (dummy) ---
@router.get("/wallet/analytics", dependencies=[Depends(master_admin_only)])
async def wallet_analytics():
    # In a real app, this data would come from complex database queries.
    return {
        "total_revenue": 123456.78,
        "active_streams": 42,
        "new_users_today": 15,
        "avg_watch_time_minutes": 28,
        "revenue_last_7_days": [
            {"day": "Mon", "revenue": 1200},
            {"day": "Tue", "revenue": 1800},
            {"day": "Wed", "revenue": 1500},
            {"day": "Thu", "revenue": 2200},
            {"day": "Fri", "revenue": 3000},
            {"day": "Sat", "revenue": 4500},
            {"day": "Sun", "revenue": 4000},
        ],
        "top_earners": [
            {"email": "host1@example.com", "earned": 5000},
            {"email": "host2@example.com", "earned": 4200},
        ]
    }

@router.get("/dashboard")
async def admin_dashboard(user = Depends(admin_or_master)):
    return {"message": f"Welcome to the admin dashboard, {user.email}!"}

# --- Coin Analytics (Admin) ---
@router.get("/coins/analytics", dependencies=[Depends(master_admin_only)])
async def coin_analytics():
    # Dummy aggregation for now
    total_coins = await users_collection.aggregate([
        {"$group": {"_id": None, "total": {"$sum": "$coins"}}}
    ]).to_list(1)
    coins_purchased = 100000  # Dummy
    coins_spent = 80000  # Dummy
    coins_payout = 20000  # Dummy
    top_spenders = [
        {"email": "spender1@demo.com", "coins": 5000},
        {"email": "spender2@demo.com", "coins": 4200},
    ]
    top_earners = [
        {"email": "host1@demo.com", "coins": 7000},
        {"email": "host2@demo.com", "coins": 6500},
    ]
    return {
        "total_coins": total_coins[0]["total"] if total_coins else 0,
        "coins_purchased": coins_purchased,
        "coins_spent": coins_spent,
        "coins_payout": coins_payout,
        "top_spenders": top_spenders,
        "top_earners": top_earners,
    }

# --- Coin Settings (Admin) ---
@router.get("/coins/settings", dependencies=[Depends(master_admin_only)])
async def get_coin_settings():
    doc = await settings_collection.find_one({"key": "coin_settings"})
    return doc["value"] if doc else {"coin_price": 1, "bonus_rate": 0}

@router.post("/coins/settings", dependencies=[Depends(master_admin_only)])
async def set_coin_settings(settings: dict = Body(...)):
    await settings_collection.update_one({"key": "coin_settings"}, {"$set": {"value": settings}}, upsert=True)
    return {"msg": "Coin settings updated"}

# --- List Pending Payout Requests (Admin) ---
@router.get("/coins/payout/requests", dependencies=[Depends(master_admin_only)])
async def list_payout_requests():
    requests = await payout_requests.find({"status": "pending"}).sort("timestamp", -1).to_list(100)
    return requests

# --- Request Payout (User/Host/Agency) ---
@router.post("/coins/payout/request")
async def request_payout(user_id: str = Body(...), amount: int = Body(...)):
    req = {
        "user_id": user_id,
        "amount": amount,
        "timestamp": datetime.utcnow(),
        "status": "pending"
    }
    await payout_requests.insert_one(req)
    await coin_transactions.insert_one(CoinTransaction(
        user_id=user_id, type="payout_requested", amount=amount, timestamp=datetime.utcnow()
    ).dict())
    return {"msg": "Payout requested"}

# --- Approve Payout (Admin) ---
@router.post("/coins/payout/approve", dependencies=[Depends(master_admin_only)])
async def approve_payout(request_id: str = Body(...)):
    req = await payout_requests.find_one({"_id": request_id, "status": "pending"})
    if not req:
        raise HTTPException(status_code=404, detail="Request not found or already processed")
    await payout_requests.update_one({"_id": request_id}, {"$set": {"status": "approved", "approved_at": datetime.utcnow()}})
    await coin_transactions.insert_one(CoinTransaction(
        user_id=req["user_id"], type="payout_approved", amount=req["amount"], timestamp=datetime.utcnow()
    ).dict())
    await users_collection.update_one({"_id": req["user_id"]}, {"$inc": {"coins": -req["amount"]}})
    return {"msg": "Payout approved"}

# --- User Coin Endpoints ---
@router.get("/coins/balance", dependencies=[Depends(admin_or_master)])
async def get_balance(current_user: User = Depends(admin_or_master)):
    user = await users_collection.find_one({"_id": current_user.id})
    return {"coins": user.get("coins", 0) if user else 0}

@router.post("/coins/purchase")
async def purchase_coins(user_id: str = Body(...), amount: int = Body(...)):
    # Simulate payment
    await users_collection.update_one({"_id": user_id}, {"$inc": {"coins": amount}})
    await coin_transactions.insert_one(CoinTransaction(
        user_id=user_id, type="purchase", amount=amount, timestamp=datetime.utcnow()
    ).dict())
    return {"msg": "Coins purchased"}

@router.post("/coins/gift")
async def gift_coins(from_user: str = Body(...), to_user: str = Body(...), amount: int = Body(...)):
    await users_collection.update_one({"_id": from_user}, {"$inc": {"coins": -amount}})
    await users_collection.update_one({"_id": to_user}, {"$inc": {"coins": amount}})
    await coin_transactions.insert_many([
        CoinTransaction(user_id=from_user, type="gift_sent", amount=-amount, timestamp=datetime.utcnow(), details=f"to {to_user}").dict(),
        CoinTransaction(user_id=to_user, type="gift_received", amount=amount, timestamp=datetime.utcnow(), details=f"from {from_user}").dict(),
    ])
    return {"msg": "Coins gifted"}

@router.get("/coins/transactions/{user_id}")
async def get_transactions(user_id: str):
    txs = await coin_transactions.find({"user_id": user_id}).sort("timestamp", -1).to_list(100)
    return txs 
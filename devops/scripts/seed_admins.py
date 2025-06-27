import os
from passlib.hash import bcrypt
from pymongo import MongoClient

MONGO_URI = os.getenv("MONGODB_URI", "mongodb://localhost:27017")
client = MongoClient(MONGO_URI)
db = client["treqsy"]
users = db["users"]

# Demo credentials
master_admin_email = "masteradmin@demo.com"
master_admin_password = "Master@123"
admin_email = "admin@demo.com"
admin_password = "Admin@123"

# Hash passwords
master_admin_hash = bcrypt.hash(master_admin_password)
admin_hash = bcrypt.hash(admin_password)

# Insert or update master admin
users.update_one(
    {"email": master_admin_email},
    {"$set": {
        "email": master_admin_email,
        "hashed_password": master_admin_hash,
        "role": "master_admin",
        "is_active": True
    }},
    upsert=True
)

# Insert or update admin
users.update_one(
    {"email": admin_email},
    {"$set": {
        "email": admin_email,
        "hashed_password": admin_hash,
        "role": "admin",
        "is_active": True
    }},
    upsert=True
)

print("Demo users created:")
print(f"Master Admin: {master_admin_email} / {master_admin_password}")
print(f"Admin: {admin_email} / {admin_password}") 
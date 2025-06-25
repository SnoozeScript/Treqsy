import asyncio
import sys
from pathlib import Path

# Add the project root to the Python path
sys.path.append(str(Path(__file__).parent.parent))

from app.db.base import init_db, get_database
from app.models.user import UserCreate, UserRole
from app.services.auth import get_password_hash

async def create_initial_data():
    db = await get_database()
    
    # Create admin user if not exists
    admin_user = await db.users.find_one({"username": "admin"})
    if not admin_user:
        admin_data = {
            "username": "admin",
            "email": "admin@livestream.app",
            "hashed_password": get_password_hash("admin123"),
            "full_name": "Admin User",
            "is_active": True,
            "is_superuser": True,
            "is_verified": True,
            "email_verified": True,
            "role": UserRole.ADMIN,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        }
        await db.users.insert_one(admin_data)
        print("Created admin user")
    
    # Create test users
    test_users = [
        {
            "username": "streamer1",
            "email": "streamer1@example.com",
            "hashed_password": get_password_hash("password123"),
            "full_name": "Streamer One",
            "is_active": True,
            "is_superuser": False,
            "is_verified": True,
            "email_verified": True,
            "role": UserRole.STREAMER,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        },
        {
            "username": "viewer1",
            "email": "viewer1@example.com",
            "hashed_password": get_password_hash("password123"),
            "full_name": "Viewer One",
            "is_active": True,
            "is_superuser": False,
            "is_verified": True,
            "email_verified": True,
            "role": UserRole.VIEWER,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        },
    ]
    
    for user in test_users:
        existing_user = await db.users.find_one({"username": user["username"]})
        if not existing_user:
            await db.users.insert_one(user)
            print(f"Created user: {user['username']}")

async def main():
    print("Initializing database...")
    await init_db()
    print("Creating initial data...")
    await create_initial_data()
    print("Database initialization complete!")

if __name__ == "__main__":
    import asyncio
    from datetime import datetime
    asyncio.run(main())

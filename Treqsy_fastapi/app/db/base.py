from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from typing import Optional
import os
from pymongo import ASCENDING, IndexModel

class DataBase:
    client: AsyncIOMotorClient = None
    db: AsyncIOMotorDatabase = None

    @classmethod
    async def connect_db(cls, db_url: str, db_name: str):
        """Connect to MongoDB."""
        cls.client = AsyncIOMotorClient(db_url)
        cls.db = cls.client[db_name]
        
        # Create indexes
        await cls._create_indexes()
        return cls.db
    
    @classmethod
    async def close_db(cls):
        """Close MongoDB connection."""
        if cls.client:
            cls.client.close()
            cls.client = None
            cls.db = None
    
    @classmethod
    async def _create_indexes(cls):
        """Create database indexes."""
        # Users collection indexes
        await cls.db.users.create_indexes([
            IndexModel([("email", ASCENDING)], unique=True, sparse=True),
            IndexModel([("phone_number", ASCENDING)], unique=True, sparse=True),
            IndexModel([("username", ASCENDING)], unique=True, sparse=True),
        ])
        
        # Streams collection indexes
        await cls.db.streams.create_indexes([
            IndexModel([("host_id", ASCENDING)]),
            IndexModel([("is_live", ASCENDING)]),
            IndexModel([("started_at", ASCENDING)]),
        ])
        
        # Add more indexes as needed

# Database instance
db = DataBase()

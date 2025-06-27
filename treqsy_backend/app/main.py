from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import auth, admin, users, streams, streaming

app = FastAPI(title="Treqsy Backend")

# CORS (Cross-Origin Resource Sharing)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

app.include_router(auth.router)
app.include_router(admin.router)
app.include_router(users.router)
app.include_router(streams.router)
app.include_router(streaming.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to the Treqsy API"} 
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from typing import List

class ConnectionManager:
    def __init__(self):
        self.active_connections: dict[str, List[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, room_id: str):
        await websocket.accept()
        if room_id not in self.active_connections:
            self.active_connections[room_id] = []
        self.active_connections[room_id].append(websocket)

    def disconnect(self, websocket: WebSocket, room_id: str):
        if room_id in self.active_connections:
            self.active_connections[room_id].remove(websocket)

    async def broadcast(self, message: str, room_id: str):
        if room_id in self.active_connections:
            for connection in self.active_connections[room_id]:
                await connection.send_text(message)

manager = ConnectionManager()
router = APIRouter(prefix="/ws", tags=["websockets"])

@router.websocket("/chat/{stream_id}")
async def websocket_endpoint(websocket: WebSocket, stream_id: str):
    await manager.connect(websocket, stream_id)
    try:
        while True:
            data = await websocket.receive_text()
            await manager.broadcast(f"Client message: {data}", stream_id)
    except WebSocketDisconnect:
        manager.disconnect(websocket, stream_id)
        await manager.broadcast(f"A client left the chat", stream_id) 
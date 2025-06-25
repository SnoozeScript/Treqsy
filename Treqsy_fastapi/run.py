#!/usr/bin/env python3
"""
Run the FastAPI application
"""
import uvicorn
from pathlib import Path
import sys

# Add the project root to the Python path
sys.path.append(str(Path(__file__).parent))

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        reload_dirs=["app"],
        reload_excludes=["*.pyc", "*.pyo", "*~"],
        reload_delay=1.0,
    )

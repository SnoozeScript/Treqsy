#!/usr/bin/env python3
"""
Set up the development environment.
"""
import os
import sys
import subprocess
from pathlib import Path

def run_command(command, cwd=None):
    """Run a shell command."""
    print(f"Running: {command}")
    try:
        subprocess.run(command, shell=True, check=True, cwd=cwd)
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {e}")
        sys.exit(1)

def main():
    """Set up the development environment."""
    # Create a virtual environment
    if not Path("venv").exists():
        print("Creating virtual environment...")
        run_command("python -m venv venv")
    
    # Activate the virtual environment and install dependencies
    if os.name == 'nt':  # Windows
        activate_cmd = ".\\venv\\Scripts\\activate"
    else:  # Unix/Linux/MacOS
        activate_cmd = "source venv/bin/activate"
    
    print("Installing dependencies...")
    run_command(f"{activate_cmd} && pip install --upgrade pip", cwd=os.getcwd())
    run_command(f"{activate_cmd} && pip install -r requirements.txt", cwd=os.getcwd())
    
    # Initialize the database
    print("Initializing database...")
    run_command(f"{activate_cmd} && python -m scripts.init_db", cwd=os.getcwd())
    
    print("\nDevelopment environment setup complete!")
    print("\nTo start the development server, run:")
    print("  python run.py")
    print("\nOr with Docker Compose:")
    print("  docker-compose up --build")

if __name__ == "__main__":
    main()

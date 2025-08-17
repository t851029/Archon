#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the project root directory
cd "$SCRIPT_DIR"

# Check if Poetry is available
if ! command -v poetry &> /dev/null; then
    echo "Error: Poetry is not installed or not in PATH"
    echo "Please install Poetry: https://python-poetry.org/docs/#installation"
    exit 1
fi

# Check if virtual environment is set up
if ! poetry env info &> /dev/null; then
    echo "Setting up Poetry virtual environment..."
    poetry install
fi

# Start the FastAPI backend
echo "Starting Living Tree FastAPI backend on port 8000..."
poetry run uvicorn api.index:app --reload --port 8000
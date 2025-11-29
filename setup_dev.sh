#!/bin/bash

# KUHP Analyzer Development Setup Script
# This script helps set up the development environment

echo "KUHP Analyzer Development Setup"
echo "=================================="

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo "[ERROR] Please run this script from the project root directory"
    exit 1
fi

echo ""
echo "Setting up environment files..."

# Setup .env files
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "[CREATED] .env from template"
else
    echo "[INFO] .env already exists"
fi

if [ ! -f "backend/.env" ]; then
    cp backend/.env.example backend/.env
    echo "[CREATED] backend/.env from template"
else
    echo "[INFO] backend/.env already exists"
fi

if [ ! -f "frontend/.env.local" ]; then
    cp frontend/.env.example frontend/.env.local
    echo "[CREATED] frontend/.env.local from template"
else
    echo "[INFO] frontend/.env.local already exists"
fi

echo ""
echo "Environment Configuration Required"
echo "-----------------------------------"
echo "Please edit the following files and add your API keys:"
echo ""
echo "1. .env - Add your GEMINI_API_KEY"
echo "2. backend/.env - Add your GEMINI_API_KEY"
echo "3. frontend/.env.local - Configure NEXT_PUBLIC_API_URL (http://localhost:8080 for local dev)"
echo ""

# Check if Docker is available
if command -v docker &> /dev/null; then
    echo "[FOUND] Docker is available"
    
    if command -v docker-compose &> /dev/null; then
        echo "[FOUND] Docker Compose is available"
        echo ""
        echo "To start the application with Docker:"
        echo "   npm run dev        # Start in foreground"
        echo "   npm run dev:detached # Start in background"
        echo "   npm run stop       # Stop containers"
        echo ""
    else
        echo "[ERROR] Docker Compose not found. Please install Docker Compose."
    fi
else
    echo "[ERROR] Docker not found. Please install Docker."
fi

# Check if Node.js is available for frontend development
if command -v node &> /dev/null; then
    echo "[FOUND] Node.js is available ($(node --version))"
    echo ""
    echo "For frontend development:"
    echo "   cd frontend"
    echo "   npm install"
    echo "   npm run dev"
    echo ""
else
    echo "[ERROR] Node.js not found. Install Node.js 18+ for frontend development."
fi

# Check if Python is available for backend development
if command -v python3 &> /dev/null; then
    echo "[FOUND] Python is available ($(python3 --version))"
    echo ""
    echo "For backend development:"
    echo "   cd backend"
    echo "   python -m venv venv"
    echo "   source venv/bin/activate  # Linux/Mac"
    echo "   pip install -r requirements.txt"
    echo "   uvicorn main:app --reload --port 8080"
    echo ""
else
    echo "[ERROR] Python3 not found. Install Python 3.11+ for backend development."
fi

echo "Testing:"
echo "   ./test_api.py                    # Test local backend"
echo "   ./test_api.py https://your-url  # Test deployed backend"
echo ""

echo "Deployment:"
echo "   ./deployment/deploy.sh PROJECT_ID REGION GEMINI_API_KEY"
echo ""

echo "For detailed instructions, see README.md"
echo ""
echo "Setup completed! Configure your API keys and start developing!"
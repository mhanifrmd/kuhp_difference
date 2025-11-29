#!/bin/bash

# KUHP Analyzer Project Verification Script
# This script verifies that all necessary files are present and properly configured

echo "KUHP Analyzer Project Verification"
echo "======================================"

PROJECT_ROOT="/Users/hanif/Documents/Work/Lexicon/Hackathon/google_build_and_blog_cloudrun_ai/kuhp_difference"
cd "$PROJECT_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERROR_COUNT=0
SUCCESS_COUNT=0

check_file() {
    if [ -f "$1" ]; then
        echo -e "[PASS] ${GREEN}$1${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "[FAIL] ${RED}$1 - MISSING${NC}"
        ((ERROR_COUNT++))
    fi
}

check_directory() {
    if [ -d "$1" ]; then
        echo -e "[PASS] ${GREEN}$1/${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "[FAIL] ${RED}$1/ - MISSING${NC}"
        ((ERROR_COUNT++))
    fi
}

echo ""
echo "Checking Project Structure..."
echo "--------------------------------"

# Check directories
check_directory "backend"
check_directory "frontend"
check_directory "frontend/app"
check_directory "documents"
check_directory "deployment"

echo ""
echo "Checking Core Files..."
echo "-------------------------"

# Check core files
check_file "README.md"
check_file "docker-compose.yml"
check_file "package.json"
check_file ".gitignore"
check_file ".env.example"

echo ""
echo "Checking Backend Files..."
echo "----------------------------"

# Backend files
check_file "backend/main.py"
check_file "backend/requirements.txt"
check_file "backend/Dockerfile"
check_file "backend/.env.example"
check_file "backend/.dockerignore"

echo ""
echo "Checking Frontend Files..."
echo "-----------------------------"

# Frontend files
check_file "frontend/package.json"
check_file "frontend/next.config.js"
check_file "frontend/tailwind.config.js"
check_file "frontend/postcss.config.js"
check_file "frontend/Dockerfile"
check_file "frontend/.env.example"
check_file "frontend/.dockerignore"
check_file "frontend/app/layout.tsx"
check_file "frontend/app/page.tsx"
check_file "frontend/app/globals.css"

echo ""
echo "Checking Document Files..."
echo "-----------------------------"

# Document files
check_file "documents/kuhp_old.pdf"
check_file "documents/kuhp_new.pdf"

echo ""
echo "Checking Deployment Files..."
echo "-------------------------------"

# Deployment files
check_file "deployment/deploy.sh"
check_file "deployment/backend.yaml"
check_file "deployment/frontend.yaml"

echo ""
echo "Checking Test Files..."
echo "-------------------------"

check_file "test_api.py"

# Check if deployment script is executable
if [ -x "deployment/deploy.sh" ]; then
    echo -e "[PASS] ${GREEN}deployment/deploy.sh is executable${NC}"
    ((SUCCESS_COUNT++))
else
    echo -e "[FAIL] ${RED}deployment/deploy.sh is not executable${NC}"
    ((ERROR_COUNT++))
fi

# Check if test script is executable
if [ -x "test_api.py" ]; then
    echo -e "[PASS] ${GREEN}test_api.py is executable${NC}"
    ((SUCCESS_COUNT++))
else
    echo -e "[FAIL] ${RED}test_api.py is not executable${NC}"
    ((ERROR_COUNT++))
fi

echo ""
echo "Verification Summary"
echo "======================"
echo -e "[PASS] ${GREEN}Successful checks: $SUCCESS_COUNT${NC}"
echo -e "[FAIL] ${RED}Failed checks: $ERROR_COUNT${NC}"

if [ $ERROR_COUNT -eq 0 ]; then
    echo ""
    echo -e "[SUCCESS] ${GREEN}Project verification completed successfully!${NC}"
    echo "   All required files are present and properly configured."
    echo ""
    echo "Next Steps:"
    echo "   1. Copy .env.example to .env and configure API keys"
    echo "   2. Run 'docker-compose up --build' for local testing"
    echo "   3. Use './deployment/deploy.sh' for Cloud Run deployment"
    echo ""
    exit 0
else
    echo ""
    echo -e "[WARNING] ${YELLOW}Project verification completed with $ERROR_COUNT errors.${NC}"
    echo "   Please fix the missing files before proceeding."
    echo ""
    exit 1
fi
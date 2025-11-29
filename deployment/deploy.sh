#!/bin/bash

# KUHP Analyzer Deployment Script for Google Cloud Run
# Make sure you have Google Cloud CLI installed and configured

set -e

# Configuration
PROJECT_ID=${1:-"your-project-id"}
REGION=${2:-"asia-southeast2"}
BACKEND_IMAGE="gcr.io/${PROJECT_ID}/kuhp-analyzer-backend"
FRONTEND_IMAGE="gcr.io/${PROJECT_ID}/kuhp-analyzer-frontend"
GEMINI_API_KEY=${3:-""}

if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "your-project-id" ]; then
    echo "Error: Please provide PROJECT_ID as first argument"
    echo "Usage: ./deploy.sh PROJECT_ID [REGION] [GEMINI_API_KEY]"
    exit 1
fi

if [ -z "$GEMINI_API_KEY" ]; then
    echo "Error: Please provide GEMINI_API_KEY as third argument or set it as environment variable"
    exit 1
fi

echo "Deploying KUHP Analyzer to Google Cloud Run..."
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"

# Enable required APIs
echo "Enabling required Google Cloud APIs..."
gcloud services enable cloudbuild.googleapis.com --project=$PROJECT_ID
gcloud services enable run.googleapis.com --project=$PROJECT_ID
gcloud services enable containerregistry.googleapis.com --project=$PROJECT_ID

# Set default project and region
gcloud config set project $PROJECT_ID
gcloud config set run/region $REGION

# Create secret for Gemini API key
echo "Creating secret for Gemini API key..."
echo -n "$GEMINI_API_KEY" | gcloud secrets create gemini-secret --data-file=- --project=$PROJECT_ID || true

# Build and push backend image
echo "Building and pushing backend image..."
cd backend
gcloud builds submit --tag $BACKEND_IMAGE --project=$PROJECT_ID
cd ..

# Deploy backend service
echo "Deploying backend service..."
gcloud run deploy kuhp-analyzer-backend \
    --image=$BACKEND_IMAGE \
    --platform=managed \
    --region=$REGION \
    --allow-unauthenticated \
    --memory=2Gi \
    --cpu=1 \
    --timeout=300 \
    --set-env-vars=PORT=8080 \
    --set-secrets=GEMINI_API_KEY=gemini-secret:latest \
    --project=$PROJECT_ID

# Get backend URL
BACKEND_URL=$(gcloud run services describe kuhp-analyzer-backend --platform=managed --region=$REGION --format='value(status.url)' --project=$PROJECT_ID)
echo "Backend deployed at: $BACKEND_URL"

# Build and push frontend image
echo "Building and pushing frontend image..."
cd frontend
gcloud builds submit --tag $FRONTEND_IMAGE --project=$PROJECT_ID
cd ..

# Deploy frontend service
echo "Deploying frontend service..."
gcloud run deploy kuhp-analyzer-frontend \
    --image=$FRONTEND_IMAGE \
    --platform=managed \
    --region=$REGION \
    --allow-unauthenticated \
    --memory=1Gi \
    --cpu=0.5 \
    --timeout=300 \
    --set-env-vars=PORT=3000,NEXT_PUBLIC_API_URL=$BACKEND_URL \
    --project=$PROJECT_ID

# Get frontend URL
FRONTEND_URL=$(gcloud run services describe kuhp-analyzer-frontend --platform=managed --region=$REGION --format='value(status.url)' --project=$PROJECT_ID)

echo ""
echo "=========================================="
echo "Deployment completed successfully!"
echo "=========================================="
echo "Frontend URL: $FRONTEND_URL"
echo "Backend URL: $BACKEND_URL"
echo ""
echo "You can now access your KUHP Analyzer application at:"
echo "$FRONTEND_URL"
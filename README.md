# KUHP Analyzer

Aplikasi web AI untuk menganalisis perbedaan antara KUHP lama dan KUHP baru menggunakan Gemini AI. Aplikasi ini memungkinkan pengguna untuk mencari pasal atau kata kunci tertentu dan mendapatkan analisis komprehensif tentang perubahan yang terjadi antara kedua versi KUHP.

## Fitur

- **Analisis AI**: Menggunakan Google Gemini untuk menganalisis perbedaan KUHP
- **Interface Modern**: Frontend Next.js yang responsif dan user-friendly
- **API Backend**: FastAPI backend yang cepat dan scalable
- **Cloud Ready**: Siap deploy ke Google Cloud Run
- **Scope Terbatas**: Hanya menjawab pertanyaan yang berkaitan dengan KUHP

## Arsitektur

```
frontend/          # Next.js frontend application
├── app/           # App Router pages
├── Dockerfile     # Frontend container config
└── package.json   # Dependencies

backend/           # FastAPI backend application
├── main.py        # Main application file
├── Dockerfile     # Backend container config
└── requirements.txt # Python dependencies

documents/         # PDF documents
├── kuhp_old.pdf   # KUHP lama
└── kuhp_new.pdf   # KUHP baru

deployment/        # Deployment configurations
├── deploy.sh      # Automated deployment script
├── backend.yaml   # Backend Cloud Run config
└── frontend.yaml  # Frontend Cloud Run config
```

## Prerequisites

### Untuk Development Lokal:
- Node.js 18 atau lebih tinggi
- Python 3.11 atau lebih tinggi
- Docker dan Docker Compose
- Google Gemini API Key

### Untuk Deployment ke Google Cloud:
- Google Cloud CLI (`gcloud`) terinstall
- Google Cloud Project dengan billing enabled
- Google Gemini API Key
- Git untuk version control

## Setup Development Lokal

### 1. Clone Repository
```bash
git clone <repository-url>
cd kuhp_difference
```

### 2. Setup Environment Variables
```bash
# Copy example environment files
cp .env.example .env
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env.local

# Edit .env files dan isi dengan API key Anda
nano .env  # Isi GEMINI_API_KEY
```

### 3. Jalankan dengan Docker Compose
```bash
# Build dan jalankan semua services
docker-compose up --build

# Atau jalankan di background
docker-compose up -d --build
```

### 4. Akses Aplikasi
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- API Docs: http://localhost:8080/docs

### 5. Development Manual (Tanpa Docker)

#### Backend:
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Linux/Mac
# atau venv\Scripts\activate  # Windows
pip install -r requirements.txt
uvicorn main:app --reload --port 8080
```

#### Frontend:
```bash
cd frontend
npm install
npm run dev
```

## Deployment ke Google Cloud Run

### Metode 1: Menggunakan Script Otomatis (Recommended)

#### 1. Persiapan
```bash
# Install Google Cloud CLI jika belum
# https://cloud.google.com/sdk/docs/install

# Login ke Google Cloud
gcloud auth login
gcloud auth application-default login

# Set project (ganti dengan project ID Anda)
export PROJECT_ID="your-project-id"
export GEMINI_API_KEY="your-gemini-api-key"
```

#### 2. Deploy dengan Script
```bash
# Jalankan script deployment
chmod +x deployment/deploy.sh
./deployment/deploy.sh $PROJECT_ID asia-southeast2 $GEMINI_API_KEY
```

#### 3. Hasil Deployment
Script akan menampilkan URL aplikasi setelah selesai:
```
Frontend URL: https://kuhp-analyzer-frontend-xxx.a.run.app
Backend URL: https://kuhp-analyzer-backend-xxx.a.run.app
```

### Metode 2: Deployment Manual

#### 1. Enable APIs
```bash
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

#### 2. Create Secret
```bash
echo -n "$GEMINI_API_KEY" | gcloud secrets create gemini-secret --data-file=-
```

#### 3. Deploy Backend
```bash
cd backend
gcloud builds submit --tag gcr.io/$PROJECT_ID/kuhp-analyzer-backend
gcloud run deploy kuhp-analyzer-backend \
    --image=gcr.io/$PROJECT_ID/kuhp-analyzer-backend \
    --platform=managed \
    --region=asia-southeast2 \
    --allow-unauthenticated \
    --memory=2Gi \
    --cpu=1 \
    --set-secrets=GEMINI_API_KEY=gemini-secret:latest
cd ..
```

#### 4. Get Backend URL
```bash
BACKEND_URL=$(gcloud run services describe kuhp-analyzer-backend \
    --platform=managed \
    --region=asia-southeast2 \
    --format='value(status.url)')
echo "Backend URL: $BACKEND_URL"
```

#### 5. Deploy Frontend
```bash
cd frontend
gcloud builds submit --tag gcr.io/$PROJECT_ID/kuhp-analyzer-frontend
gcloud run deploy kuhp-analyzer-frontend \
    --image=gcr.io/$PROJECT_ID/kuhp-analyzer-frontend \
    --platform=managed \
    --region=asia-southeast2 \
    --allow-unauthenticated \
    --memory=1Gi \
    --cpu=0.5 \
    --set-env-vars=NEXT_PUBLIC_API_URL=$BACKEND_URL
cd ..
```

## Configuration

### Environment Variables

#### Backend (.env):
```env
GEMINI_API_KEY=your_gemini_api_key_here
PORT=8080
```

#### Frontend (.env.local):
```env
NEXT_PUBLIC_API_URL=https://your-backend-url.run.app
```

### API Endpoints

#### Backend API:
- `GET /` - Health check
- `POST /analyze` - Analyze KUHP differences
- `GET /health` - Detailed health check
- `GET /docs` - Interactive API documentation

#### Request Format:
```json
{
  "query": "Pasal 351 tentang penganiayaan"
}
```

#### Response Format:
```json
{
  "response": "Analisis perbedaan...",
  "is_relevant": true
}
```

## Testing

### Test API dengan cURL:
```bash
# Health check
curl https://your-backend-url.run.app/health

# Analyze query
curl -X POST https://your-backend-url.run.app/analyze \
  -H "Content-Type: application/json" \
  -d '{"query": "Pasal 351"}'
```

### Test Frontend:
1. Buka aplikasi di browser
2. Masukkan query: "Pasal 351"
3. Klik "Analisis Perbedaan"
4. Verifikasi response yang relevan

## Monitoring

### Cloud Run Metrics:
- CPU utilization
- Memory usage
- Request count
- Response time
- Error rate

### Logs:
```bash
# Backend logs
gcloud logs tail kuhp-analyzer-backend --region=asia-southeast2

# Frontend logs  
gcloud logs tail kuhp-analyzer-frontend --region=asia-southeast2
```

## Security

- API keys disimpan sebagai Google Cloud Secrets
- CORS dikonfigurasi untuk production
- No authentication required (public access)
- Input validation di backend
- Rate limiting dari Cloud Run

## Cost Estimation

Estimasi biaya Google Cloud Run (per bulan):
- Backend: ~$10-30 (tergantung usage)
- Frontend: ~$5-15 (tergantung traffic)
- Storage: ~$1-5
- **Total: ~$16-50/bulan**

## Troubleshooting

### Error: "Permission denied"
```bash
gcloud auth login
gcloud auth application-default login
```

### Error: "Service not found"
```bash
gcloud services enable run.googleapis.com
```

### Error: "Image not found"
```bash
# Rebuild image
gcloud builds submit --tag gcr.io/$PROJECT_ID/service-name
```

### Error: "Secret not found"
```bash
# Recreate secret
echo -n "$GEMINI_API_KEY" | gcloud secrets create gemini-secret --data-file=-
```

### Frontend tidak bisa connect ke Backend:
1. Check NEXT_PUBLIC_API_URL environment variable
2. Verify backend service is running
3. Check CORS configuration

## Usage Examples

### Contoh Query yang Valid:
- "Pasal 351 tentang penganiayaan"
- "perbedaan pidana pembunuhan"
- "Bab XVI tentang kejahatan terhadap keamanan negara"
- "sanksi pencurian dalam KUHP baru"

### Contoh Query yang Ditolak:
- "Bagaimana cara masak nasi?"
- "Siapa presiden Indonesia?"
- "Cuaca hari ini bagaimana?"

## Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## License

This project is licensed under the MIT License.

## Support

Untuk pertanyaan atau dukungan teknis, silakan buat issue di repository ini.

---

**Dibuat dengan menggunakan Next.js, FastAPI, dan Google Gemini AI**
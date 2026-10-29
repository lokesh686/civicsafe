# CivicSafe Deployment Guide

This guide covers deploying CivicSafe to various platforms.

## Quick Start (Local Development)

```bash
# Clone the repo
git clone https://github.com/lokesh686/civicsafe.git
cd civicsafe

# Copy environment file
cp .env.production.example .env
# Edit .env with your values

# Start with Docker Compose
docker-compose up -d
```

Services:
- Frontend: http://localhost
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- PostgreSQL: localhost:5432

---

## Production Deployment Options

### Option 1: Railway (Easiest - Recommended)

1. **Create Railway project**: https://railway.app
2. **Add PostgreSQL**: New → Database → PostgreSQL
3. **Deploy Backend**:
   - New → Deploy from GitHub Repo
   - Select `civicsafe` repo
   - Root Directory: `backend`
   - Add environment variables from `.env.production.example`
4. **Deploy Frontend**:
   - New → Deploy from GitHub Repo
   - Root Directory: `frontend`
   - Uses Dockerfile automatically
5. **Configure Custom Domains** in Railway settings

### Option 2: Render

1. **Create Render account**: https://render.com
2. **PostgreSQL**: New → PostgreSQL (free tier available)
3. **Backend Web Service**:
   - New → Web Service → Connect GitHub
   - Root Directory: `backend`
   - Build Command: `uv sync --frozen --no-dev`
   - Start Command: `uv run uvicorn main:app --host 0.0.0.0 --port $PORT`
   - Environment: Python 3.11
4. **Frontend Static Site**:
   - New → Static Site → Connect GitHub
   - Root Directory: `frontend`
   - Build Command: `flutter build web --release`
   - Publish Directory: `build/web`
   - Note: Flutter on Render needs custom build script

### Option 3: Fly.io

```bash
# Install flyctl
curl -L https://fly.io/install.sh | sh

# Login
fly auth login

# Launch backend
cd backend
fly launch --name civicsafe-backend --region iad --no-deploy
# Edit fly.toml to set env vars
fly secrets set DATABASE_URL=... SECRET_KEY=...
fly deploy

# Launch frontend
cd ../frontend
fly launch --name civicsafe-frontend --region iad --no-deploy
fly deploy
```

### Option 4: Google Cloud Run

```bash
# Build and push backend
gcloud builds submit --tag gcr.io/PROJECT_ID/civicsafe-backend ./backend

# Deploy backend
gcloud run deploy civicsafe-backend \
  --image gcr.io/PROJECT_ID/civicsafe-backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars DATABASE_URL=...,SECRET_KEY=...

# Build and push frontend
gcloud builds submit --tag gcr.io/PROJECT_ID/civicsafe-frontend ./frontend

# Deploy frontend
gcloud run deploy civicsafe-frontend \
  --image gcr.io/PROJECT_ID/civicsafe-frontend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Option 5: AWS ECS / ECR

1. Push images to ECR
2. Create ECS cluster and task definitions
3. Use Application Load Balancer
4. Configure RDS PostgreSQL

### Option 6: DigitalOcean App Platform

1. Connect GitHub repo
2. Add backend as "Worker" or "Service" component
3. Add frontend as "Static Site" component
4. Add managed PostgreSQL database

---

## Required Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection string (asyncpg format) | Yes |
| `SECRET_KEY` | JWT signing key (32+ chars) | Yes |
| `API_URL` | Production backend URL | Yes |
| `ALGORITHM` | JWT algorithm (HS256) | No |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Token expiry (default 1440) | No |
| `HASHING_SCHEME` | Password hash (bcrypt/pbkdf2_sha256) | No |
| `GOOGLE_SHEET_ID` | Google Sheet for analytics export | No |
| `GOOGLE_DRIVE_FOLDER_ID` | Drive folder for image storage | No |
| `GOOGLE_CREDENTIALS_JSON` | Service account JSON | No |

Generate `SECRET_KEY`:
```bash
openssl rand -hex 32
```

---

## Database Setup

The backend auto-creates tables on startup via SQLAlchemy lifespan. For production:

1. Run migrations manually (recommended):
```bash
# In backend container
alembic upgrade head
```

2. Or let the app create tables on first run (development only)

---

## Frontend Production Build

For web deployment, the frontend uses `--dart-define` for API URL:

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://api.yourdomain.com
```

For mobile apps:
```bash
# Android
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.yourdomain.com

# iOS
flutter build ios --release \
  --dart-define=API_BASE_URL=https://api.yourdomain.com
```

---

## SSL/HTTPS

All production platforms provide automatic HTTPS:
- Railway: Automatic
- Render: Automatic
- Fly.io: Automatic with `flyctl certs`
- Cloud Run: Automatic
- Custom: Use Cloudflare, Let's Encrypt, or your load balancer

---

## Monitoring & Logs

- **Railway**: Built-in metrics dashboard
- **Render**: Built-in logs and metrics
- **Fly.io**: `flyctl logs`, Grafana integration
- **Cloud Run**: Cloud Logging, Cloud Monitoring
- **Self-hosted**: Prometheus + Grafana, ELK stack

---

## Scaling Considerations

1. **Database**: Use connection pooling (PgBouncer for PostgreSQL)
2. **Backend**: Run multiple replicas behind load balancer
3. **Frontend**: Static files served via CDN (Cloudflare, CloudFront)
4. **File Storage**: Move images to S3/GCS/Blob Storage (currently stored in DB)
5. **Background Jobs**: Add Celery + Redis for async tasks

---

## Troubleshooting

### Backend won't start
- Check `DATABASE_URL` format: `postgresql+asyncpg://user:pass@host:5432/db?sslmode=require`
- Verify database is accessible from deployment platform
- Check `SECRET_KEY` is set

### Frontend can't connect to API
- Verify `API_BASE_URL` in build matches backend domain
- Check CORS settings in backend (currently allows all origins)
- Check browser network tab for failed requests

### Database connection errors
- Ensure `sslmode=require` for managed PostgreSQL
- Check firewall/security groups allow connections
- Verify connection string encoding (special chars in password)

---

## Cost Estimation (Monthly)

| Platform | Backend | Frontend | Database | Total |
|----------|---------|----------|----------|-------|
| Railway | $5-20 | $5 | $5 | $15-30 |
| Render | Free-$7 | Free | Free-$7 | $0-14 |
| Fly.io | $5-15 | $5 | $5-15 | $15-35 |
| Cloud Run | Pay per use | Pay per use | Cloud SQL ~$15 | Variable |
| DigitalOcean | $5-12 | $5 | $15 | $25-32 |

---

## Next Steps

1. Choose a platform based on budget and familiarity
2. Set up managed PostgreSQL
3. Configure environment variables
4. Deploy backend first, test API endpoints
5. Deploy frontend with correct API URL
6. Set up custom domain and SSL
7. Configure monitoring and alerts
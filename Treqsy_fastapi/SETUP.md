# LiveStream Platform - Backend Setup Guide

## 🚀 Production Deployment

### Prerequisites

- Docker and Docker Compose
- Python 3.9+
- MongoDB 5.0+
- Redis 6.0+
- AWS Account (for S3, CloudFront, etc.)
- Domain with SSL certificate

## 🛠 Installation

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/livestream_platform.git
cd livestream_fastapi
```

### 2. Set up environment variables
Create a `.env` file based on `.env.example`:
```bash
cp .env.example .env
```

### 3. Build and run with Docker (Recommended for Production)
```bash
docker-compose -f docker-compose.prod.yml up --build -d
```

## 🔧 Configuration

### Environment Variables
Edit the `.env` file with your production settings:

```env
# Application
APP_ENV=production
DEBUG=false
SECRET_KEY=your-secret-key-here
FRONTEND_URL=https://your-frontend-domain.com

# Database
MONGODB_URL=mongodb://user:password@mongodb:27017/livestream
REDIS_URL=redis://redis:6379/0

# JWT
JWT_SECRET_KEY=your-jwt-secret
JWT_REFRESH_SECRET_KEY=your-refresh-secret
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=7

# AWS
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_STORAGE_BUCKET_NAME=your-s3-bucket
AWS_S3_REGION=your-region

# Email (SMTP)
SMTP_TLS=True
SMTP_PORT=587
SMTP_HOST=smtp.example.com
SMTP_USER=your-email@example.com
SMTP_PASSWORD=your-email-password
EMAILS_FROM_EMAIL=no-reply@yourdomain.com
EMAILS_FROM_NAME="LiveStream Platform"

# Security
CORS_ORIGINS=https://your-frontend-domain.com,https://www.your-frontend-domain.com
```

## 🚀 Deployment

### 1. AWS ECS (Recommended)
1. Install AWS CLI and configure with your credentials
2. Install and configure AWS ECS CLI
3. Deploy:
   ```bash
   ./deploy-ecs.sh
   ```

### 2. Kubernetes
1. Install kubectl and configure for your cluster
2. Apply configurations:
   ```bash
   kubectl apply -f k8s/
   ```

## 📊 Monitoring & Logging

### 1. Prometheus & Grafana
- Prometheus endpoint: `/metrics`
- Grafana dashboard: `monitoring/grafana/dashboards`

### 2. Logging
- Logs are sent to CloudWatch by default
- Access logs at AWS CloudWatch

## 🔒 Security

### 1. SSL/TLS
- Use AWS Certificate Manager or Let's Encrypt
- Configure in your load balancer or reverse proxy

### 2. Rate Limiting
- Global rate limiting: 1000 requests/minute
- Authentication endpoints: 5 requests/minute

## 🔄 CI/CD

GitHub Actions workflows are configured in `.github/workflows/`:
- `ci.yml`: Run tests on push
- `cd.yml`: Deploy to production on tag

## 🛠 Development

### 1. Local Development
```bash
# Start dependencies
docker-compose up -d mongodb redis

# Install Python dependencies
python -m venv venv
source venv/bin/activate  # On Windows: .\venv\Scripts\activate
pip install -r requirements.txt

# Run migrations
alembic upgrade head

# Start the development server
uvicorn app.main:app --reload
```

### 2. Running Tests
```bash
pytest
```

## 📚 API Documentation

- Swagger UI: `/docs`
- ReDoc: `/redoc`
- OpenAPI schema: `/openapi.json`

## 📞 Support

For issues and feature requests, please use the [GitHub Issues](https://github.com/yourusername/livestream_platform/issues).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

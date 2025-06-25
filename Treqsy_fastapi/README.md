# LiveStream Platform Backend

A high-performance backend for the LiveStream Platform built with FastAPI, MongoDB, and Python.

## Features

- **User Authentication**: JWT-based authentication with email/phone verification
- **RESTful API**: Clean and well-documented API endpoints
- **Real-time Updates**: WebSocket support for real-time features
- **File Uploads**: Support for image and video uploads with S3 integration
- **Rate Limiting**: Protect your API from abuse
- **CORS**: Configured for web and mobile clients
- **Docker Support**: Easy deployment with Docker
- **Environment Configuration**: Simple configuration with environment variables

## Prerequisites

- Python 3.8+
- MongoDB 4.4+
- Redis (for rate limiting and caching)
- Docker (optional)

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/livestream-backend.git
cd livestream-backend
```

### 2. Create a virtual environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure environment variables

Copy the example environment file and update the values:

```bash
cp .env.example .env
```

Edit the `.env` file with your configuration.

### 5. Run the application

```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`

### 6. Access the API documentation

- Swagger UI: `http://localhost:8000/api/docs`
- ReDoc: `http://localhost:8000/api/redoc`

## Project Structure

```
livestream-backend/
├── app/
│   ├── api/                   # API routes
│   │   └── v1/                # API version 1
│   │       ├── endpoints/     # API endpoints
│   │       └── api.py         # API router
│   ├── core/                  # Core functionality
│   │   ├── config.py          # Application settings
│   │   └── security.py        # Authentication and security
│   ├── db/                    # Database configuration
│   ├── models/                # Database models
│   ├── schemas/               # Pydantic models
│   ├── services/              # Business logic
│   └── utils/                 # Utility functions
├── tests/                     # Test files
├── .env                       # Environment variables
├── .gitignore
├── docker-compose.yml         # Docker Compose configuration
├── Dockerfile                 # Docker configuration
├── requirements.txt           # Project dependencies
└── README.md
```

## API Documentation

### Authentication

All API endpoints (except public ones) require authentication. Include the JWT token in the `Authorization` header:

```
Authorization: Bearer your-jwt-token
```

### Available Endpoints

#### Auth

- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/signup` - User registration
- `POST /api/v1/auth/refresh-token` - Refresh access token
- `POST /api/v1/auth/forgot-password` - Request password reset
- `POST /api/v1/auth/reset-password` - Reset password
- `POST /api/v1/auth/verify-email` - Verify email

#### Users

- `GET /api/v1/users/me` - Get current user profile
- `PUT /api/v1/users/me` - Update current user profile
- `GET /api/v1/users/{user_id}` - Get user by ID

## Deployment

### With Docker

1. Build the Docker image:

```bash
docker-compose build
```

2. Start the services:

```bash
docker-compose up -d
```

The API will be available at `http://localhost:8000`

### Without Docker

1. Install MongoDB and Redis
2. Create and activate a virtual environment
3. Install dependencies: `pip install -r requirements.txt`
4. Set up environment variables in `.env`
5. Run the application: `uvicorn app.main:app --host 0.0.0.0 --port 8000`

## Environment Variables

See `.env.example` for all available environment variables.

## Testing

To run tests:

```bash
pytest
```

## Contributing

1. Fork the repository
2. Create a new branch: `git checkout -b feature/my-feature`
3. Make your changes and commit them: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

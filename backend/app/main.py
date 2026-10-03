import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routes.artisans import router as artisans_router
from .routes.ai import router as ai_router

_development_origins = [
    "http://localhost:3000",
    "http://localhost:5000",
    "http://localhost:5173",
    "http://localhost:8000",
    "http://localhost:8080",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:5000",
    "http://127.0.0.1:5173",
    "http://127.0.0.1:8000",
    "http://127.0.0.1:8080",
]
_frontend_origins = [
    origin.strip().rstrip("/")
    for origin in os.getenv("FRONTEND_ORIGIN", "").split(",")
    if origin.strip()
]

app = FastAPI(
    title="KalaSaathi API",
    description="Backend API for the KalaSaathi artisan marketplace",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[*_development_origins, *_frontend_origins],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(artisans_router)
app.include_router(ai_router)


@app.get("/")
def root():
    return {
        "message": "Welcome to KalaSaathi API",
        "status": "running",
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
    }
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routes.artisans import router as artisans_router
from .routes.ai import router as ai_router

app = FastAPI(
    title="KalaSaathi API",
    description="Backend API for the KalaSaathi artisan marketplace",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
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
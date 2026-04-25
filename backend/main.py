"""
HailMary Health — FastAPI Backend
Emergency-first, AI-assisted health response system for patients.

This is the main application entry point. It sets up CORS, mounts
all route modules, and serves static mock assets.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pathlib import Path

from database.database import engine, Base, SessionLocal
from database.seeder import seed_database

from routes.emergency import router as emergency_router
from routes.ml import router as ml_router
from routes.records import router as records_router
from routes.dashboard import router as dashboard_router
from routes.asha import router as asha_router
from routes.chat import router as chat_router

# ─── App Initialization ────────────────────────────────────────

app = FastAPI(
    title="HailMary Health API",
    description="Emergency-first, AI-assisted health response backend for patients.",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# ─── CORS ───────────────────────────────────────────────────────

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Static Files (mock assets) ────────────────────────────────

mock_dir = Path(__file__).parent / "mock"
mock_dir.mkdir(exist_ok=True)
app.mount("/mock", StaticFiles(directory=str(mock_dir)), name="mock")

# Ensure data directory exists
data_dir = Path(__file__).parent / "data"
data_dir.mkdir(exist_ok=True)

# ─── Route Registration ────────────────────────────────────────

app.include_router(emergency_router)
app.include_router(ml_router)
app.include_router(records_router)
app.include_router(dashboard_router)
app.include_router(asha_router)
app.include_router(chat_router)


# ─── Health Check ───────────────────────────────────────────────

@app.get("/", tags=["Health"])
async def health_check():
    """
    Health check endpoint.
    Returns service status and available endpoints.
    """
    return {
        "status": "healthy",
        "service": "HailMary Health API",
        "version": "1.0.0",
        "endpoints": {
            "emergency": "POST /emergency",
            "analyze_xray": "POST /ml/analyze",
            "process_vitals": "POST /ml/vitals",
            "list_records": "GET /records",
            "create_record": "POST /records",
            "dashboard_summary": "GET /dashboard/summary",
            "docs": "GET /docs",
        },
    }


# ─── Startup Event ──────────────────────────────────────────────

@app.on_event("startup")
async def startup():
    print("=" * 60)
    print("  [+] HailMary Health API -- Starting Up")
    
    # Initialize Database Tables
    try:
        Base.metadata.create_all(bind=engine)
        print("  [+] PostgreSQL Database synced successfully.")
        
        # Run mock data seeder
        db = SessionLocal()
        seed_database(db)
        db.close()
    except Exception as e:
        print(f"  [!] Database connection failed: {e}")
        
    print("  [>] Docs:    http://localhost:8000/docs")
    print("  [>] ReDoc:   http://localhost:8000/redoc")
    print("=" * 60)

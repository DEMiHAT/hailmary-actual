"""
ASHA Worker routes — Pulls ASHA worker assignments and patient histories from PostgreSQL.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from database.database import get_db
from database.models import AshaWorker, Patient, HealthRecord

router = APIRouter(prefix="/asha", tags=["ASHA Workers"])

@router.get("/workers")
async def get_asha_workers(db: Session = Depends(get_db)):
    """
    Retrieve a list of all active ASHA workers from PostgreSQL.
    """
    workers = db.query(AshaWorker).filter(AshaWorker.is_active == True).all()
    return workers


@router.get("/workers/{worker_id}/patients")
async def get_worker_patients(worker_id: str, db: Session = Depends(get_db)):
    """
    Retrieves all patients assigned to a specific ASHA worker, including their current TPS score.
    """
    worker = db.query(AshaWorker).filter(AshaWorker.id == worker_id).first()
    if not worker:
        raise HTTPException(status_code=404, detail="ASHA Worker not found")

    patients = db.query(Patient).filter(Patient.assigned_worker_id == worker_id).all()
    return patients


@router.get("/patients/{patient_id}/history")
async def get_patient_history(patient_id: str, db: Session = Depends(get_db)):
    """
    Retrieves the entire chronological health history (records) for a specific patient.
    """
    patient = db.query(Patient).filter(Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")

    return patient.records

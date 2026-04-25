from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Text, JSON, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
import uuid

from .database import Base

def generate_uuid():
    return str(uuid.uuid4())

class AshaWorker(Base):
    __tablename__ = "asha_workers"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    name = Column(String, nullable=False)
    region = Column(String, nullable=False)
    phone_number = Column(String)
    is_active = Column(Boolean, default=True)

    # Relationship to patients
    patients = relationship("Patient", back_populates="assigned_worker")


class Patient(Base):
    __tablename__ = "patients"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    name = Column(String, nullable=False)
    age = Column(Integer)
    gender = Column(String)
    tps_score = Column(Float, default=0.0)
    risk_level = Column(String, default="LOW")  # LOW, MEDIUM, HIGH

    assigned_worker_id = Column(String, ForeignKey("asha_workers.id"))
    assigned_worker = relationship("AshaWorker", back_populates="patients")
    
    records = relationship("HealthRecord", back_populates="patient", order_by="desc(HealthRecord.date_created)")


class HealthRecord(Base):
    __tablename__ = "health_records"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    
    record_type = Column(String, nullable=False) # 'xray', 'vitals', 'emergency', 'adherence'
    result_summary = Column(Text, nullable=False)
    risk_level = Column(String, default="LOW")
    details = Column(JSON, default=dict)
    
    date_created = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    patient = relationship("Patient", back_populates="records")

from sqlalchemy.orm import Session
from database.models import AshaWorker, Patient, HealthRecord

def seed_database(db: Session):
    # Check if we already seeded
    if db.query(AshaWorker).first():
        print("Database already seeded.")
        return

    print("Seeding PostgreSQL with initial ASHA workers and patient data...")

    # 1. Create ASHA Workers
    worker1 = AshaWorker(name="Lakshmi Devi", region="Bangalore South", phone_number="+91-9876543210")
    worker2 = AshaWorker(name="Priya Sharma", region="Bangalore North", phone_number="+91-8765432109")
    worker3 = AshaWorker(name="Anjali Kumar", region="Mysore Central", phone_number="+91-7654321098")

    db.add_all([worker1, worker2, worker3])
    db.commit()

    # 2. Create Patients
    patient1 = Patient(
        id="patient_001",
        name="Rahul V.",
        age=34,
        gender="Male",
        tps_score=85.0,
        risk_level="LOW",
        assigned_worker_id=worker1.id
    )

    patient2 = Patient(
        id="patient_002",
        name="Sneha M.",
        age=28,
        gender="Female",
        tps_score=40.0,
        risk_level="HIGH",
        assigned_worker_id=worker2.id
    )

    db.add_all([patient1, patient2])
    db.commit()

    # 3. Create Sample Health Records
    r1 = HealthRecord(
        patient_id=patient1.id,
        record_type="vitals",
        result_summary="HR: 72 BPM • SpO₂: 97%",
        risk_level="LOW",
        details={"heart_rate": 72, "spo2_estimate": 97}
    )

    r2 = HealthRecord(
        patient_id=patient1.id,
        record_type="xray",
        result_summary="Tuberculosis — Confidence: 89%",
        risk_level="MEDIUM",
        details={"prediction": "tuberculosis", "confidence": 0.89}
    )

    r3 = HealthRecord(
        patient_id=patient2.id,
        record_type="adherence",
        result_summary="3 consecutive missed doses",
        risk_level="HIGH",
        details={"missed_count": 3}
    )

    db.add_all([r1, r2, r3])
    db.commit()

    print("Seeding complete.")

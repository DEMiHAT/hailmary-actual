"""
Dashboard routes — Returns composite tracking data for the frontend dashboard.
"""

from fastapi import APIRouter
from pydantic import BaseModel
from typing import List, Dict, Any

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


class MonitoringModule(BaseModel):
    id: str
    title: str
    value: str
    status: str  # e.g., 'safe', 'warning', 'info'
    subtitle: str
    weight: str


class WeightTrend(BaseModel):
    current: float
    target: float
    weekly_history: List[float]


class SymptomLog(BaseModel):
    name: str
    severity: str
    status: str


class DashboardSummaryResponse(BaseModel):
    tps_score: int
    adherence_rate: int
    adherence_history: List[str]  # e.g., 'taken', 'missed', 'empty'
    breathlessness_mmrc: int
    modules: List[MonitoringModule]
    weight_trend: WeightTrend
    symptoms: List[SymptomLog]
    alerts: List[str]


@router.get("/summary", response_model=DashboardSummaryResponse)
async def get_dashboard_summary(user_id: str = "patient_001"):
    """
    Retrieve the composite dashboard status for a given user.
    This serves as the single source of truth for the frontend dashboard tabs.
    """
    # In a real system, this data would be aggregated across databases and ML models.
    # Currently returning a structurally accurate mock payload that matches the UI requirements.
    return DashboardSummaryResponse(
        tps_score=85,
        adherence_rate=93,
        adherence_history=[
            # Week 1
            "taken", "taken", "taken", "taken", "missed", "taken", "taken",
            # Week 2
            "taken", "taken", "taken", "taken", "missed", "taken", "taken",
            # Empty Days (next week padding)
            "empty", "empty"
        ],
        breathlessness_mmrc=1,
        modules=[
            MonitoringModule(id="cough", title="Cough Acoustics", value="0.71", status="info", subtitle="Recovery Index", weight="30%"),
            MonitoringModule(id="xray", title="Chest X-Ray / CV", value="Mild", status="warning", subtitle="White patch detected", weight="20%"),
            MonitoringModule(id="adherence", title="Med. Adherence", value="93%", status="info", subtitle="14-day window", weight="20%"),
            MonitoringModule(id="spo2", title="SpO₂ Monitor", value="97%", status="safe", subtitle="Camera PPG · Normal", weight="10%"),
            MonitoringModule(id="breath", title="Breathlessness", value="mMRC 1", status="safe", subtitle="Mild, hurrying only", weight="20%"),
            MonitoringModule(id="weight", title="Weight Track", value="+0.8kg", status="info", subtitle="This fortnight", weight="10%"),
        ],
        weight_trend=WeightTrend(
            current=64.8,
            target=66.0,
            weekly_history=[64.0, 64.1, 64.3, 64.8]
        ),
        symptoms=[
            SymptomLog(name="Fever", severity="None", status="safe"),
            SymptomLog(name="Fatigue", severity="Mild", status="warning"),
            SymptomLog(name="Chest Pain", severity="None", status="safe"),
            SymptomLog(name="Haemoptysis", severity="None", status="safe"),
        ],
        alerts=["2 missed doses detected. ASHA worker notified via Ni-Kshay dashboard."]
    )

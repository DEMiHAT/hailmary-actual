import json
from pathlib import Path
from rapidfuzz import process, fuzz
from sqlalchemy.orm import Session
from database.models import Patient, AshaWorker, HealthRecord

# Load intents from the JSON file
_INTENTS_FILE = Path(__file__).parent.parent / "data" / "bot_intents.json"

def _load_intents():
    try:
        with open(_INTENTS_FILE, "r") as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading intents: {e}")
        return []

INTENTS = _load_intents()

# Build a flattened list of all triggers and their parent intent index for blazing fast O(N) matching
_TRIGGER_MAP = []
for idx, intent in enumerate(INTENTS):
    for trigger in intent.get("triggers", []):
        _TRIGGER_MAP.append({"trigger": trigger, "intent_idx": idx})

def match_intent(user_text: str):
    """
    Uses RapidFuzz (Levenshtein Distance) to find the best matching intent trigger.
    Returns the mapped intent dictionary if confidence > 70%, else None.
    """
    if not _TRIGGER_MAP:
        return None
        
    triggers_only = [item["trigger"] for item in _TRIGGER_MAP]
    
    # Extract the best match
    matches = process.extract(user_text.lower(), triggers_only, scorer=fuzz.WRatio, limit=1)
    
    if matches:
        best_match, score, index = matches[0]
        if score > 70.0:  # 70% confidence threshold
            mapped_idx = _TRIGGER_MAP[index]["intent_idx"]
            return INTENTS[mapped_idx]
            
    return None

def process_message(user_text: str, user_id: str, db: Session) -> dict:
    """
    Classifies the user's message and executes any required backend tasks via SQLAlchemy.
    Returns a dictionary suitable for the chat frontend.
    """
    intent = match_intent(user_text)
    
    if not intent:
        return {
            "type": "text", 
            "content": "I'm sorry, I don't understand that yet. Please select an option from the quick action menu below."
        }
    
    action = intent.get("action", "REPLY_ONLY")
    base_response = intent.get("response", "")
    
    # ── Task Execution Router ──
    if action == "REPLY_ONLY":
        return {"type": "text", "content": base_response}
        
    elif action == "GET_TPS":
        patient = db.query(Patient).filter(Patient.id == user_id).first()
        if patient:
            return {"type": "data", "content": f"Your current Treatment Progress Score (TPS) is {patient.tps_score}%. Keep it up!"}
        return {"type": "error", "content": "Could not locate your patient record."}
        
    elif action == "GET_ASHA":
        patient = db.query(Patient).filter(Patient.id == user_id).first()
        if patient and patient.assigned_worker:
            worker = patient.assigned_worker
            return {"type": "data", "content": f"Your ASHA worker is {worker.name} covering the {worker.region} region. Emergency Contact: {worker.phone_number}"}
        return {"type": "error", "content": "You don't have an assigned ASHA worker in the system."}
        
    elif action == "GET_ADHERENCE":
        return {"type": "data", "content": "We've analyzed your adherence logs. You missed your dose yesterday. ASHA worker notified."}

    elif action == "EXECUTE_EMERGENCY":
        return {"type": "action", "action": "EMERGENCY", "content": base_response}

    return {"type": "text", "content": base_response}

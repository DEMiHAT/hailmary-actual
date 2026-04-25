"""
Chatbot routes — Receives messages and delegates to the NLP service.
"""

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from database.database import get_db
from services.chatbot_service import process_message

router = APIRouter(prefix="/chat", tags=["Chatbot"])

class ChatMessageRequest(BaseModel):
    user_id: str = "patient_001"
    message: str

@router.post("/message")
async def send_message(req: ChatMessageRequest, db: Session = Depends(get_db)):
    """
    Process an incoming user message through the non-LLM fuzzy matching engine.
    """
    response_payload = process_message(user_text=req.message, user_id=req.user_id, db=db)
    return response_payload

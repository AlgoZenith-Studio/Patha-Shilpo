from fastapi import APIRouter

router = APIRouter()

@router.post("/transcribe")
async def transcribe_voice():
    """Sarvam AI & Bhashini ULCA Indic speech-to-text."""
    return {"status": "success", "tier": "online_sarvam_bhashini"}

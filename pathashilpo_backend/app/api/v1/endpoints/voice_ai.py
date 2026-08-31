from fastapi import APIRouter, Depends, Form, HTTPException, UploadFile, status

from app.core.security import get_current_user
from app.schemas.ai import VoiceResponse
from app.services import bhashini_service, sarvam_service
from app.services.bhashini_service import BhashiniError
from app.services.sarvam_service import SarvamError

router = APIRouter()


@router.post("", response_model=VoiceResponse)
async def transcribe_voice(
    file: UploadFile,
    source_language: str = Form(...),
    _user=Depends(get_current_user),
) -> VoiceResponse:
    audio_bytes = await file.read()

    try:
        result = await sarvam_service.transcribe(audio_bytes, source_language)
        return VoiceResponse(**result, tier=1, source="sarvam")
    except SarvamError:
        pass

    try:
        result = await bhashini_service.transcribe(audio_bytes, source_language)
        return VoiceResponse(**result, tier=1, source="bhashini")
    except BhashiniError:
        pass

    raise HTTPException(
        status_code=status.HTTP_502_BAD_GATEWAY,
        detail="Both Sarvam and Bhashini speech recognition are unavailable. "
        "Client should fall back to on-device ASR.",
    )

"""Speech-to-text — Tier 1 of the speech chain (PROJECT_CONTEXT §3).

Sarvam first, Bhashini second, then a 502 telling the client to fall back to
the Android recogniser (Tier 2) and finally record-and-form (Tier 3). The 502
is an ordinary outcome, not an incident.
"""

import logging

from fastapi import APIRouter, Depends, Form, HTTPException, UploadFile, status

from app.core.rate_limit import ai_limiter
from app.core.security import AuthenticatedUser, get_current_user
from app.schemas.ai import VoiceResponse
from app.services import bhashini_service, sarvam_service
from app.services.bhashini_service import BhashiniError
from app.services.sarvam_service import SarvamError

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("", response_model=VoiceResponse)
async def transcribe_voice(
    file: UploadFile,
    source_language: str = Form(...),
    user: AuthenticatedUser = Depends(get_current_user),
) -> VoiceResponse:
    ai_limiter.check(user.uid)

    audio_bytes = await file.read()
    if not audio_bytes:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Audio file is empty.",
        )

    try:
        result = await sarvam_service.transcribe(audio_bytes, source_language)
        # A 200 carrying an empty transcript is a failure as far as the
        # artisan is concerned — it would produce a blank listing. Treat it
        # like a provider error and give Bhashini a turn.
        if result["transcript"].strip():
            return VoiceResponse(**result, tier=1, source="sarvam")
        logger.info("Sarvam returned an empty transcript; trying Bhashini")
    except SarvamError:
        pass

    try:
        result = await bhashini_service.transcribe(audio_bytes, source_language)
        if result["transcript"].strip():
            return VoiceResponse(**result, tier=1, source="bhashini")
        logger.info("Bhashini returned an empty transcript; falling to device ASR")
    except BhashiniError:
        pass

    raise HTTPException(
        status_code=status.HTTP_502_BAD_GATEWAY,
        detail="Both Sarvam and Bhashini speech recognition are unavailable. "
        "Client should fall back to on-device ASR.",
    )

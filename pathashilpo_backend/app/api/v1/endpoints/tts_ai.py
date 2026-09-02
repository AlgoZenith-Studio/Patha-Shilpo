"""Text-to-speech — the Hindi readback of the price rationale (PRD §6 step 4).

Same tiering as `/ai/voice` in the opposite direction: Sarvam first, Bhashini
second, then a 502 that tells the client to speak the text with `flutter_tts`
on the device (§8.5). A 502 here is a normal, expected outcome — it is how
the offline twin gets its turn — so it must stay cheap and fast rather than
retrying.
"""

import base64
import logging

from fastapi import APIRouter, Depends, HTTPException, status

from app.core.rate_limit import ai_limiter
from app.core.security import AuthenticatedUser, get_current_user
from app.schemas.ai import TtsRequest, TtsResponse
from app.services import bhashini_service, sarvam_service
from app.services.bhashini_service import BhashiniError
from app.services.sarvam_service import SarvamError

logger = logging.getLogger(__name__)

router = APIRouter()

# Both providers return WAV for these voices.
AUDIO_CONTENT_TYPE = "audio/wav"


@router.post("", response_model=TtsResponse)
async def synthesize_speech(
    payload: TtsRequest,
    user: AuthenticatedUser = Depends(get_current_user),
) -> TtsResponse:
    ai_limiter.check(user.uid)

    try:
        audio = await sarvam_service.synthesize(
            payload.text, payload.language_code, speaker=payload.speaker
        )
        return TtsResponse(
            audio=base64.b64encode(audio).decode("ascii"),
            content_type=AUDIO_CONTENT_TYPE,
            language_code=payload.language_code,
            source="sarvam",
        )
    except SarvamError:
        pass

    try:
        audio = await bhashini_service.synthesize(
            payload.text, payload.language_code, gender=payload.gender
        )
        return TtsResponse(
            audio=base64.b64encode(audio).decode("ascii"),
            content_type=AUDIO_CONTENT_TYPE,
            language_code=payload.language_code,
            source="bhashini",
        )
    except BhashiniError:
        pass

    logger.info(
        "TTS unavailable for %s; client falls back to flutter_tts",
        payload.language_code,
    )
    raise HTTPException(
        status_code=status.HTTP_502_BAD_GATEWAY,
        detail="Both Sarvam and Bhashini speech synthesis are unavailable. "
        "Client should fall back to on-device TTS.",
    )

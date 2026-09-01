from fastapi import APIRouter, Depends, UploadFile

from app.core.rate_limit import ai_limiter
from app.core.security import AuthenticatedUser, get_current_user
from app.schemas.ai import ImageResponse
from app.services import fal_service

router = APIRouter()


@router.post("", response_model=ImageResponse)
async def process_image(
    file: UploadFile,
    user: AuthenticatedUser = Depends(get_current_user),
) -> ImageResponse:
    ai_limiter.check(user.uid)

    image_bytes = await file.read()
    result = await fal_service.process_image(
        image_bytes, content_type=file.content_type or "image/jpeg"
    )
    return ImageResponse(**result)

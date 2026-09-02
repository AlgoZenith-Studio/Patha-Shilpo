"""Image processing — background removal and enhancement (TRD.md §8.4).

Never fails to the client: `fal_service.process_image` degrades to the
original image rather than raising, so the artisan keeps whatever the
on-device crop/pad produced. The guards below run *before* that, and only
reject uploads that are not images at all or are large enough to be abuse.
"""

from fastapi import APIRouter, Depends, HTTPException, UploadFile, status

from app.core.rate_limit import ai_limiter
from app.core.security import AuthenticatedUser, get_current_user
from app.schemas.ai import ImageResponse
from app.services import fal_service

router = APIRouter()

# The client uploads `processed.jpg` (≤300 KB) or at worst `original.jpg`
# (≤1.5 MB) per the §9.5 payload budget. 4 MB leaves generous headroom while
# still stopping a signed-in caller from pushing a 50 MB body into a paid
# pipeline.
MAX_IMAGE_BYTES = 4 * 1024 * 1024


@router.post("", response_model=ImageResponse)
async def process_image(
    file: UploadFile,
    user: AuthenticatedUser = Depends(get_current_user),
) -> ImageResponse:
    ai_limiter.check(user.uid)

    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Image file is empty.",
        )

    # Checked before decoding so a huge upload is rejected without Pillow
    # trying to parse it.
    if len(image_bytes) > MAX_IMAGE_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_CONTENT_TOO_LARGE,
            detail=f"Image exceeds the {MAX_IMAGE_BYTES // (1024 * 1024)} MB limit.",
        )

    # Sniffed from the bytes, not read from the Content-Type header: the
    # Flutter client sends multipart without an explicit contentType, so the
    # header arrives as application/octet-stream.
    content_type = fal_service.detect_image_type(image_bytes)
    if content_type is None:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="File is not a readable JPEG, PNG or WebP image.",
        )

    result = await fal_service.process_image(image_bytes, content_type=content_type)
    return ImageResponse(**result)

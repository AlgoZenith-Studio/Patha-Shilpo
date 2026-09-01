from fastapi import APIRouter, Depends

from app.core.rate_limit import ai_limiter
from app.core.security import AuthenticatedUser, get_current_user
from app.schemas.ai import ListingRequest, ListingResponse
from app.services import gemini_service

router = APIRouter()


@router.post("", response_model=ListingResponse)
async def generate_listing(
    payload: ListingRequest,
    user: AuthenticatedUser = Depends(get_current_user),
) -> ListingResponse:
    ai_limiter.check(user.uid)

    result = await gemini_service.generate_listing(
        transcript=payload.transcript,
        craft_type=payload.craft_type,
        material=payload.material,
        colors=payload.colors,
        hours_of_work=payload.hours_of_work,
    )
    return ListingResponse(
        title=result["title"],
        title_hi=result["titleHi"],
        description=result["description"],
        description_hi=result["descriptionHi"],
        tags=result["tags"],
        colors=result["colors"],
        material=result["material"],
        craft_type=result["craftType"],
        generated_by=result["generated_by"],
    )

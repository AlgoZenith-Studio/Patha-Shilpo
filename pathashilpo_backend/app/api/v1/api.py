from fastapi import APIRouter

from app.api.v1.endpoints import image_ai, listing_ai, voice_ai

api_router = APIRouter()

api_router.include_router(listing_ai.router, prefix="/ai/listing", tags=["ai"])
api_router.include_router(image_ai.router, prefix="/ai/image", tags=["ai"])
api_router.include_router(voice_ai.router, prefix="/ai/voice", tags=["ai"])

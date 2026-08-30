from fastapi import APIRouter
from app.api.v1.endpoints import (
    auth,
    image_ai,
    voice_ai,
    listing_ai,
    products,
    enquiries,
    rfq,
    sync,
)

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(image_ai.router, prefix="/ai/image", tags=["Vision AI (fal.ai)"])
api_router.include_router(voice_ai.router, prefix="/ai/voice", tags=["Voice AI (Sarvam & Bhashini)"])
api_router.include_router(listing_ai.router, prefix="/ai/listing", tags=["Listing AI (Gemini)"])
api_router.include_router(products.router, prefix="/products", tags=["Products & Catalog"])
api_router.include_router(enquiries.router, prefix="/enquiries", tags=["Buyer Inquiries"])
api_router.include_router(rfq.router, prefix="/rfq", tags=["Bulk RFQs"])
api_router.include_router(sync.router, prefix="/sync", tags=["Offline Sync Engine"])

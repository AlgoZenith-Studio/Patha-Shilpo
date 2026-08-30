from fastapi import APIRouter

router = APIRouter()

@router.post("/")
async def create_enquiry():
    """Submit buyer inquiry to artisan."""
    return {"status": "enquiry_submitted"}

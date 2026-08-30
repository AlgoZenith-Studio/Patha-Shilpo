from fastapi import APIRouter

router = APIRouter()

@router.post("/")
async def create_rfq():
    """Submit bulk Request-for-Quote (RFQ)."""
    return {"status": "rfq_created"}

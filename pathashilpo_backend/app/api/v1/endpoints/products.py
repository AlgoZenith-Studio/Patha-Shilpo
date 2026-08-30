from fastapi import APIRouter

router = APIRouter()

@router.get("/")
async def list_products():
    """Browse live products with craft, price, and tag filters."""
    return {"products": []}

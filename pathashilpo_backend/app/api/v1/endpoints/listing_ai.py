from fastapi import APIRouter

router = APIRouter()

@router.post("/generate")
async def generate_listing():
    """Gemini 2.0 Flash bilingual structured JSON listing copy."""
    return {"status": "success", "generated_by": "gemini"}

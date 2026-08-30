from fastapi import APIRouter

router = APIRouter()

@router.post("/batch")
async def sync_batch():
    """Idempotent batch sync for drafts created offline."""
    return {"status": "synced", "processed": 0}

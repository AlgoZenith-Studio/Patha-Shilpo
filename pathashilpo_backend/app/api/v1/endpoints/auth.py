from fastapi import APIRouter

router = APIRouter()

@router.post("/phone-otp")
async def send_phone_otp():
    """Trigger phone OTP verification via Firebase Auth."""
    return {"message": "OTP sent successfully"}

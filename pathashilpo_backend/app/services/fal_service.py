import asyncio
import base64
import io
import os

import fal_client
from PIL import Image, ImageFilter, ImageStat

from app.core.config import get_settings

BACKGROUND_REMOVAL_MODEL = "fal-ai/birefnet"
UPSCALE_MODEL = "fal-ai/clarity-upscaler"


def _quality_score(image_bytes: bytes) -> float:
    """Cheap sharpness/contrast heuristic (0..1), not a replacement for the
    on-device MobileNetV3/Laplacian check — just enough signal for the API
    response contract."""
    try:
        with Image.open(io.BytesIO(image_bytes)) as img:
            grayscale = img.convert("L")
            edges = grayscale.filter(ImageFilter.FIND_EDGES)
            variance = ImageStat.Stat(edges).var[0]
        return min(variance / 2000.0, 1.0)
    except Exception:
        return 0.0


def _to_data_uri(image_bytes: bytes, content_type: str) -> str:
    encoded = base64.b64encode(image_bytes).decode("ascii")
    return f"data:{content_type};base64,{encoded}"


def _submit(model: str, arguments: dict) -> dict:
    return fal_client.subscribe(model, arguments=arguments, with_logs=False)


async def _run_with_timeout(model: str, arguments: dict, timeout: float) -> dict:
    return await asyncio.wait_for(
        asyncio.to_thread(_submit, model, arguments),
        timeout=timeout,
    )


async def process_image(image_bytes: bytes, content_type: str = "image/jpeg") -> dict:
    settings = get_settings()
    quality_score = _quality_score(image_bytes)

    if not settings.FAL_KEY:
        return {
            "image_url": _to_data_uri(image_bytes, content_type),
            "background_removed": False,
            "enhanced": False,
            "quality_score": quality_score,
            "degraded": True,
        }

    os.environ.setdefault("FAL_KEY", settings.FAL_KEY)
    data_uri = _to_data_uri(image_bytes, content_type)

    try:
        bg_result = await _run_with_timeout(
            BACKGROUND_REMOVAL_MODEL, {"image_url": data_uri}, timeout=30.0
        )
        processed_url = bg_result["image"]["url"]
        background_removed = True
        degraded = False
    except Exception:
        return {
            "image_url": data_uri,
            "background_removed": False,
            "enhanced": False,
            "quality_score": quality_score,
            "degraded": True,
        }

    enhanced = False
    try:
        upscale_result = await _run_with_timeout(
            UPSCALE_MODEL, {"image_url": processed_url}, timeout=30.0
        )
        processed_url = upscale_result["image"]["url"]
        enhanced = True
    except Exception:
        pass  # enhancement is best-effort; keep the bg-removed image

    return {
        "image_url": processed_url,
        "background_removed": background_removed,
        "enhanced": enhanced,
        "quality_score": quality_score,
        "degraded": degraded,
    }

"""fal.ai client — background removal and enhancement (TRD.md §8.4).

Two models in sequence: `birefnet` cuts the background out, then
`clarity-upscaler` sharpens the result. Only the first is load-bearing — an
un-upscaled cutout is a perfectly good listing image, so enhancement failure
is swallowed while background-removal failure degrades the whole response.

**This service never raises.** The artisan is standing in front of a Review
screen when it runs, and invariant 3 (PROJECT_CONTEXT §7) says they are never
blocked by an error they must resolve. Every failure path returns the original
image with `degraded: true`, and the client keeps its offline crop/pad result.
"""

import asyncio
import base64
import io
import logging
import os
import time

import fal_client
from PIL import Image, ImageFilter, ImageStat

from app.core.config import get_settings

logger = logging.getLogger(__name__)

BACKGROUND_REMOVAL_MODEL = "fal-ai/birefnet"
UPSCALE_MODEL = "fal-ai/clarity-upscaler"

# §8.4: "Timeout 30 s total" — for the whole call, not per model. The §8.5
# failure matrix also allows one retry, so the budget is enforced as a shared
# deadline rather than a per-request timeout; otherwise a retried background
# removal plus an upscale could hold the request open for 90 s.
TOTAL_BUDGET_SECONDS = 30.0
BACKGROUND_REMOVAL_ATTEMPTS = 2

# Below this there is no point starting another round trip.
MIN_ATTEMPT_SECONDS = 3.0


def _quality_score(image_bytes: bytes) -> float:
    """Cheap sharpness/contrast heuristic (0..1).

    Not a replacement for the on-device Laplacian check — just enough signal
    to populate the API response contract.
    """
    try:
        with Image.open(io.BytesIO(image_bytes)) as img:
            grayscale = img.convert("L")
            edges = grayscale.filter(ImageFilter.FIND_EDGES)
            variance = ImageStat.Stat(edges).var[0]
        return min(variance / 2000.0, 1.0)
    except Exception:
        # Pillow raises a wide range of types for a corrupt or unsupported
        # upload; an unreadable image scores zero rather than 500ing.
        logger.warning("Could not score image quality", exc_info=True)
        return 0.0


# Pillow format name -> MIME type, for the formats the pipeline accepts.
_SUPPORTED_FORMATS = {
    "JPEG": "image/jpeg",
    "PNG": "image/png",
    "WEBP": "image/webp",
}


def detect_image_type(image_bytes: bytes) -> str | None:
    """The image's real MIME type, or None if it is not a supported image.

    Sniffs the bytes rather than trusting the upload's Content-Type header.
    The header is caller-supplied and, in our own client, absent: Dio's
    `MultipartFile.fromBytes` sends `application/octet-stream` unless a
    contentType is passed explicitly, so header-based validation would reject
    every photo the app sends.
    """
    try:
        with Image.open(io.BytesIO(image_bytes)) as img:
            return _SUPPORTED_FORMATS.get(img.format or "")
    except Exception:
        # Pillow raises many types for malformed input; none of them mean
        # anything more useful than "not an image we can process".
        return None


def _to_data_uri(image_bytes: bytes, content_type: str) -> str:
    encoded = base64.b64encode(image_bytes).decode("ascii")
    return f"data:{content_type};base64,{encoded}"


def _degraded(image_url: str, quality_score: float) -> dict:
    return {
        "image_url": image_url,
        "background_removed": False,
        "enhanced": False,
        "quality_score": quality_score,
        "degraded": True,
    }


def _submit(model: str, arguments: dict) -> dict:
    # fal_client is synchronous, so it runs on a worker thread to keep the
    # event loop free.
    return fal_client.subscribe(model, arguments=arguments, with_logs=False)


async def _run_with_timeout(model: str, arguments: dict, timeout: float) -> dict:
    return await asyncio.wait_for(
        asyncio.to_thread(_submit, model, arguments),
        timeout=timeout,
    )


async def _remove_background(data_uri: str, deadline: float) -> str | None:
    """Returns the processed image URL, or None if every attempt failed."""
    for attempt in range(BACKGROUND_REMOVAL_ATTEMPTS):
        remaining = deadline - time.monotonic()
        if remaining < MIN_ATTEMPT_SECONDS:
            logger.warning(
                "Skipping background-removal attempt %d: %.1fs of budget left",
                attempt + 1,
                remaining,
            )
            return None

        try:
            result = await _run_with_timeout(
                BACKGROUND_REMOVAL_MODEL, {"image_url": data_uri}, timeout=remaining
            )
            return result["image"]["url"]
        except asyncio.TimeoutError:
            logger.warning(
                "fal.ai background removal timed out (attempt %d/%d)",
                attempt + 1,
                BACKGROUND_REMOVAL_ATTEMPTS,
            )
        except (KeyError, TypeError):
            # Response shape changed — retrying will not help.
            logger.exception("fal.ai background removal returned an unexpected shape")
            return None
        except Exception:
            # Deliberately broad: fal_client surfaces provider, transport and
            # queue errors as unrelated types, and none of them may reach the
            # artisan. Logged with a traceback so it stops being invisible.
            logger.exception(
                "fal.ai background removal failed (attempt %d/%d)",
                attempt + 1,
                BACKGROUND_REMOVAL_ATTEMPTS,
            )

    return None


async def _enhance(image_url: str, deadline: float) -> str | None:
    """Best-effort upscale. Returns None to keep the background-removed image."""
    remaining = deadline - time.monotonic()
    if remaining < MIN_ATTEMPT_SECONDS:
        logger.info("Skipping enhancement: %.1fs of budget left", remaining)
        return None

    try:
        result = await _run_with_timeout(
            UPSCALE_MODEL, {"image_url": image_url}, timeout=remaining
        )
        return result["image"]["url"]
    except asyncio.TimeoutError:
        logger.info("fal.ai enhancement timed out; keeping the cutout")
        return None
    except Exception:
        logger.warning("fal.ai enhancement failed; keeping the cutout", exc_info=True)
        return None


async def process_image(image_bytes: bytes, content_type: str = "image/jpeg") -> dict:
    """Background-remove and enhance one image.

    Always returns a usable response; `degraded: true` means the caller should
    keep whatever the on-device pipeline produced.
    """
    settings = get_settings()
    quality_score = _quality_score(image_bytes)
    data_uri = _to_data_uri(image_bytes, content_type)

    if not settings.FAL_KEY:
        logger.info("FAL_KEY not configured; returning the original image")
        return _degraded(data_uri, quality_score)

    os.environ.setdefault("FAL_KEY", settings.FAL_KEY)
    deadline = time.monotonic() + TOTAL_BUDGET_SECONDS

    processed_url = await _remove_background(data_uri, deadline)
    if processed_url is None:
        return _degraded(data_uri, quality_score)

    enhanced_url = await _enhance(processed_url, deadline)

    return {
        "image_url": enhanced_url or processed_url,
        "background_removed": True,
        "enhanced": enhanced_url is not None,
        "quality_score": quality_score,
        "degraded": False,
    }

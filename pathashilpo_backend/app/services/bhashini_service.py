"""Bhashini (ULCA) client — ASR, TTS and translation (TRD.md §8.2).

Bhashini is the **fallback** provider throughout: Sarvam is primary for both
speech-to-text and text-to-speech, and Bhashini covers the languages and
dialects Sarvam handles poorly. It is free public infrastructure (PRD §10),
which is why it is worth keeping wired even though it is slower.

Every call is a two-step dance, which is what makes this client more involved
than `sarvam_service`:

  1. POST getModelsPipeline  → a pipeline config naming a callback URL, an
                               inference key, and a `serviceId` per task
  2. POST {callbackUrl}      → the actual compute request

Step 1 is slow and identical for every call with the same task and language
pair, so it is cached in-process for the life of the server (TRD.md §8.2:
"cache the pipeline config for the session; do not re-fetch per call").

**No API key is required to import this module.** Every entry point raises
`BhashiniError` when `BHASHINI_API_KEY` / `BHASHINI_USER_ID` are unset, and
each caller treats that as "fall through to the next tier" — so the backend
runs correctly with Bhashini unconfigured, which is the current state.
"""

import base64
import logging

import httpx

from app.core.config import get_settings

logger = logging.getLogger(__name__)

PIPELINE_CONFIG_URL = (
    "https://meity-auth.ulcacontrib.org/ulca/apis/v0/model/getModelsPipeline"
)

# MeitY's public pipeline. ULCA requires a pipeline id up front; this is the
# one Bhashini documents for general use.
MEITY_PIPELINE_ID = "64392f96daac500b55c543cd"

# Per the §8.5 failure matrix. TTS is tighter than ASR because it runs while
# the artisan is looking at a Review screen waiting to hear the price read
# out — a slow readback is worse than falling straight to `flutter_tts`.
ASR_TIMEOUT = 10.0
TTS_TIMEOUT = 8.0
TRANSLATE_TIMEOUT = 10.0

TASK_ASR = "asr"
TASK_TTS = "tts"
TASK_TRANSLATION = "translation"

# Keyed by (task, source_language, target_language) rather than by language
# alone. An ASR config and a TTS config for Hindi are different documents
# carrying different serviceIds, so a language-only key would hand a TTS call
# the ASR pipeline and fail deep inside the compute request.
_pipeline_cache: dict[tuple[str, str, str | None], dict] = {}


class BhashiniError(Exception):
    """Any Bhashini failure. Callers treat this as 'try the next tier'."""


def _credentials() -> tuple[str, str]:
    settings = get_settings()
    if not settings.BHASHINI_API_KEY or not settings.BHASHINI_USER_ID:
        raise BhashiniError("BHASHINI_API_KEY/BHASHINI_USER_ID not configured")
    return settings.BHASHINI_USER_ID, settings.BHASHINI_API_KEY


def _language_config(source_language: str, target_language: str | None) -> dict:
    language = {"sourceLanguage": source_language}
    if target_language:
        language["targetLanguage"] = target_language
    return {"language": language}


async def _get_pipeline_config(
    task: str,
    source_language: str,
    target_language: str | None = None,
) -> dict:
    cache_key = (task, source_language, target_language)
    if cache_key in _pipeline_cache:
        return _pipeline_cache[cache_key]

    user_id, api_key = _credentials()

    async with httpx.AsyncClient(timeout=ASR_TIMEOUT) as client:
        response = await client.post(
            PIPELINE_CONFIG_URL,
            headers={"userID": user_id, "ulcaApiKey": api_key},
            json={
                "pipelineTasks": [
                    {
                        "taskType": task,
                        "config": _language_config(source_language, target_language),
                    }
                ],
                "pipelineRequestConfig": {"pipelineId": MEITY_PIPELINE_ID},
            },
        )
        response.raise_for_status()
        config = response.json()

    _pipeline_cache[cache_key] = config
    return config


def _extract_callback(config: dict) -> tuple[str, dict]:
    """Pull the compute URL and its auth header out of a pipeline config."""
    endpoint = config["pipelineInferenceAPIEndPoint"]
    callback_url = endpoint["callbackUrl"]
    inference_key = endpoint["inferenceApiKey"]
    return callback_url, {inference_key["name"]: inference_key["value"]}


def _service_id(config: dict, task: str) -> str | None:
    """The model ULCA picked for this task.

    The compute request is supposed to name it explicitly; without it ULCA
    either rejects the call or silently picks a different model than the one
    the config was negotiated for. Returns None if absent so a config shape
    change degrades to the old behaviour rather than raising.
    """
    for entry in config.get("pipelineResponseConfig", []):
        if entry.get("taskType") != task:
            continue
        for candidate in entry.get("config", []):
            service_id = candidate.get("serviceId")
            if service_id:
                return service_id
    return None


def _task_config(
    task: str,
    config: dict,
    source_language: str,
    target_language: str | None = None,
    **extra: object,
) -> dict:
    task_config = _language_config(source_language, target_language)
    service_id = _service_id(config, task)
    if service_id:
        task_config["serviceId"] = service_id
    task_config.update(extra)
    return {"taskType": task, "config": task_config}


async def _compute(
    task: str,
    source_language: str,
    input_data: dict,
    timeout: float,
    target_language: str | None = None,
    **task_extra: object,
) -> dict:
    """Run one ULCA task end to end, invalidating the cache on failure.

    A cached config holds a callback URL and an inference key that ULCA can
    rotate or expire. Dropping the entry on any failure means the next attempt
    re-negotiates instead of retrying forever against a dead endpoint.
    """
    cache_key = (task, source_language, target_language)
    try:
        config = await _get_pipeline_config(task, source_language, target_language)
        callback_url, auth_headers = _extract_callback(config)

        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.post(
                callback_url,
                headers=auth_headers,
                json={
                    "pipelineTasks": [
                        _task_config(
                            task,
                            config,
                            source_language,
                            target_language,
                            **task_extra,
                        )
                    ],
                    "inputData": input_data,
                },
            )
            response.raise_for_status()
            return response.json()
    except (httpx.HTTPError, BhashiniError, KeyError, ValueError) as exc:
        _pipeline_cache.pop(cache_key, None)
        # Log the type and task, never the response body — a ULCA error can
        # echo the inference key back (§5.4).
        logger.warning(
            "Bhashini %s failed (%s); falling through to the next tier",
            task,
            type(exc).__name__,
        )
        raise BhashiniError(f"Bhashini {task} failed: {type(exc).__name__}") from exc


async def transcribe(audio_bytes: bytes, source_language: str) -> dict:
    """Speech-to-text. Returns {transcript, language_code, confidence}."""
    data = await _compute(
        TASK_ASR,
        source_language,
        {"audio": [{"audioContent": base64.b64encode(audio_bytes).decode("ascii")}]},
        ASR_TIMEOUT,
    )

    try:
        output = data["pipelineResponse"][0]["output"][0]
    except (KeyError, IndexError) as exc:
        raise BhashiniError("Bhashini ASR response had no output") from exc

    # ULCA does not always return a confidence. 0.8 is the "accepted, unscored"
    # value the client uses to decide whether to show the transcript for
    # confirmation; it must not be 0.0, which the client reads as a failure.
    confidence = output.get("confidence")
    return {
        "transcript": output.get("source", ""),
        "language_code": source_language,
        "confidence": float(confidence) if confidence is not None else 0.8,
    }


async def synthesize(
    text: str,
    language_code: str,
    gender: str = "female",
) -> bytes:
    """Text-to-speech. Returns raw audio bytes.

    Used for the Hindi price rationale readback (PRD §6 step 4). Falls to
    `flutter_tts` on the device when this raises (§8.5).
    """
    if not text.strip():
        raise BhashiniError("Cannot synthesize empty text")

    data = await _compute(
        TASK_TTS,
        language_code,
        {"input": [{"source": text}]},
        TTS_TIMEOUT,
        gender=gender,
    )

    try:
        audio_b64 = data["pipelineResponse"][0]["audio"][0]["audioContent"]
    except (KeyError, IndexError) as exc:
        raise BhashiniError("Bhashini TTS response had no audio") from exc

    if not audio_b64:
        raise BhashiniError("Bhashini TTS returned empty audio")

    try:
        return base64.b64decode(audio_b64)
    except (ValueError, TypeError) as exc:
        raise BhashiniError("Bhashini TTS audio was not valid base64") from exc


async def translate(text: str, source_language: str, target_language: str) -> str:
    """Machine translation between two Indic languages (or to/from English)."""
    if not text.strip():
        return ""

    data = await _compute(
        TASK_TRANSLATION,
        source_language,
        {"input": [{"source": text}]},
        TRANSLATE_TIMEOUT,
        target_language=target_language,
    )

    try:
        return data["pipelineResponse"][0]["output"][0].get("target", "")
    except (KeyError, IndexError) as exc:
        raise BhashiniError("Bhashini translation response had no output") from exc


def clear_pipeline_cache() -> None:
    """Test hook, and a way to force re-negotiation without a restart."""
    _pipeline_cache.clear()

import base64

import httpx

from app.core.config import get_settings

PIPELINE_CONFIG_URL = "https://meity-auth.ulcacontrib.org/ulca/apis/v0/model/getModelsPipeline"
TIMEOUT = 10.0

# In-process cache of {source_language: pipeline_config}, per TRD §8.2:
# "Cache the pipeline config for the session; do not re-fetch per call."
_pipeline_cache: dict[str, dict] = {}


class BhashiniError(Exception):
    pass


async def _get_pipeline_config(source_language: str) -> dict:
    if source_language in _pipeline_cache:
        return _pipeline_cache[source_language]

    settings = get_settings()
    if not settings.BHASHINI_API_KEY or not settings.BHASHINI_USER_ID:
        raise BhashiniError("BHASHINI_API_KEY/BHASHINI_USER_ID not configured")

    async with httpx.AsyncClient(timeout=TIMEOUT) as client:
        response = await client.post(
            PIPELINE_CONFIG_URL,
            headers={
                "userID": settings.BHASHINI_USER_ID,
                "ulcaApiKey": settings.BHASHINI_API_KEY,
            },
            json={
                "pipelineTasks": [
                    {
                        "taskType": "asr",
                        "config": {"language": {"sourceLanguage": source_language}},
                    }
                ],
                "pipelineRequestConfig": {"pipelineId": "64392f96daac500b55c543cd"},
            },
        )
        response.raise_for_status()
        config = response.json()

    _pipeline_cache[source_language] = config
    return config


def _extract_callback(config: dict) -> tuple[str, dict]:
    callback_url = config["pipelineInferenceAPIEndPoint"]["callbackUrl"]
    inference_key = config["pipelineInferenceAPIEndPoint"]["inferenceApiKey"]
    headers = {inference_key["name"]: inference_key["value"]}
    return callback_url, headers


async def transcribe(audio_bytes: bytes, source_language: str) -> dict:
    """Speech-to-text via ULCA. Returns {transcript, language_code, confidence}."""
    try:
        config = await _get_pipeline_config(source_language)
        callback_url, auth_headers = _extract_callback(config)

        async with httpx.AsyncClient(timeout=TIMEOUT) as client:
            response = await client.post(
                callback_url,
                headers=auth_headers,
                json={
                    "pipelineTasks": [
                        {
                            "taskType": "asr",
                            "config": {"language": {"sourceLanguage": source_language}},
                        }
                    ],
                    "inputData": {
                        "audio": [{"audioContent": base64.b64encode(audio_bytes).decode("ascii")}]
                    },
                },
            )
            response.raise_for_status()
            data = response.json()
    except (httpx.HTTPError, BhashiniError, KeyError) as exc:
        _pipeline_cache.pop(source_language, None)
        raise BhashiniError(str(exc)) from exc

    output = data["pipelineResponse"][0]["output"][0]
    return {
        "transcript": output.get("source", ""),
        "language_code": source_language,
        "confidence": float(output.get("confidence", 0.0)) if "confidence" in output else 0.8,
    }

import json
import re

import httpx

from app.core.config import get_settings

GEMINI_URL = (
    "https://generativelanguage.googleapis.com/v1beta/models/"
    "gemini-2.0-flash:generateContent"
)

REQUIRED_KEYS = (
    "title",
    "titleHi",
    "description",
    "descriptionHi",
    "tags",
    "colors",
    "material",
    "craftType",
)

_FENCE_RE = re.compile(r"^```(?:json)?\s*|\s*```$", re.MULTILINE)


def _build_prompt(transcript: str, craft_type: str, material: str | None, colors: list[str], hours_of_work: int | None) -> str:
    return (
        "You are writing a bilingual (English + Hindi) marketplace listing for a "
        "handmade craft product sold by a rural Indian artisan.\n\n"
        f"Craft type: {craft_type}\n"
        f"Material: {material or 'unspecified'}\n"
        f"Colors: {', '.join(colors) if colors else 'unspecified'}\n"
        f"Hours of work: {hours_of_work if hours_of_work is not None else 'unspecified'}\n"
        f"Artisan's spoken description (may be transcribed from Hindi or a regional dialect): "
        f"\"{transcript}\"\n\n"
        "Return ONLY a JSON object with exactly these keys: title, titleHi, description, "
        "descriptionHi, tags, colors, material, craftType. "
        "title <= 70 chars, description <= 600 chars, tags is an array of 6-8 lowercase strings, "
        "colors is an array of strings, titleHi/descriptionHi are the Hindi translations."
    )


def _strip_fences(text: str) -> str:
    return _FENCE_RE.sub("", text).strip()


async def _call_gemini(prompt: str, api_key: str) -> dict:
    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 0.4,
            "maxOutputTokens": 800,
            "responseMimeType": "application/json",
        },
    }
    async with httpx.AsyncClient(timeout=12.0) as client:
        response = await client.post(
            GEMINI_URL,
            params={"key": api_key},
            json=payload,
        )
        response.raise_for_status()
        body = response.json()

    text = body["candidates"][0]["content"]["parts"][0]["text"]
    parsed = json.loads(_strip_fences(text))

    if not all(key in parsed for key in REQUIRED_KEYS):
        raise ValueError("Gemini response missing required keys")

    return parsed


async def generate_listing(
    transcript: str,
    craft_type: str,
    material: str | None = None,
    colors: list[str] | None = None,
    hours_of_work: int | None = None,
) -> dict:
    colors = colors or []
    settings = get_settings()
    prompt = _build_prompt(transcript, craft_type, material, colors, hours_of_work)

    if settings.GEMINI_API_KEY:
        for attempt in range(2):  # initial attempt + 1 retry
            try:
                parsed = await _call_gemini(prompt, settings.GEMINI_API_KEY)
                return {**parsed, "generated_by": "gemini"}
            except (httpx.HTTPError, ValueError, KeyError, json.JSONDecodeError):
                if attempt == 1:
                    break

    return generate_template_listing(transcript, craft_type, material, colors, hours_of_work)


def generate_template_listing(
    transcript: str,
    craft_type: str,
    material: str | None = None,
    colors: list[str] | None = None,
    hours_of_work: int | None = None,
) -> dict:
    colors = colors or []
    material_label = material or "handcrafted material"
    color_label = colors[0] if colors else ""

    title_parts = [craft_type.strip().title()]
    if color_label:
        title_parts.append(f"in {color_label}")
    if material:
        title_parts.append(f"({material})")
    title = " ".join(title_parts).strip()

    title_hi = f"{craft_type} — {material_label}"

    description = f"Handwoven {craft_type} made from {material_label}."
    if hours_of_work:
        description += f" Crafted over {hours_of_work} hours by a skilled artisan."
    if transcript:
        description += f" Artisan's note: {transcript.strip()}"

    description_hi = f"{craft_type} हस्तनिर्मित है, {material_label} से बना है।"

    tags = list(dict.fromkeys(
        [t.lower() for t in [craft_type, material or "", *colors, "handmade", "artisan"] if t]
    ))[:8]

    return {
        "title": title[:70],
        "titleHi": title_hi[:70],
        "description": description[:600],
        "descriptionHi": description_hi[:600],
        "tags": tags,
        "colors": colors,
        "material": material_label,
        "craftType": craft_type,
        "generated_by": "template",
    }

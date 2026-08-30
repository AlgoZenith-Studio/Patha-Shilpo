<div align="center">

# Pathashilpa · पथ-शिल्प · পাথ-শিল্প

**Your craft. Your price. Your name.**

An offline-first, voice-guided cataloguing and fair-pricing platform for rural Indian artisans.

*Smart India Hackathon 2026 · AI-Driven Market Linkage and Smart Cataloging for Marginalized Artisans*

</div>

---

## What it does

An artisan photographs a handicraft, speaks a description in their own language, and enters two numbers. Pathashilpa returns a complete bilingual product listing with a fair, **explained** price — and it does all of this **in airplane mode**, syncing and silently upgrading the moment a network appears.

> **The problem:** 0.2% of handloom sales happen online, while 95.5% of rural mobile owners already own a smartphone. The device barrier is gone. What's missing is software the artisan can operate.

**Positioning:** not another marketplace — the layer that *creates* the listing every other marketplace requires.

---

## Documentation

| Document | What's in it |
| :--- | :--- |
| [`PRD.md`](PRD.md) | Product requirements — problem, users, scope, journeys, business model, landing-page spec |
| [`TRD.md`](TRD.md) | Technical requirements — **full product architecture and the MVP subset**, schemas, API contracts, security rules, budgets |
| [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) | **Single source of truth** — reconciled stack, design system, invariants, live build status |

The TRD covers two tiers at once, marked throughout: 🟢 **MVP** (building now) · 🟡 **MVP-partial** (mocked, labelled as such) · 🔵 **Post-MVP** (designed, deferred). Scope matrix in §1.2; deferred architecture in §19.

**Precedence:** shipped code → `TRD.md` → `PROJECT_CONTEXT.md` → `PRD.md`. Unresolved conflicts are tracked in `PROJECT_CONTEXT.md` §10.

---

## Repository layout

```
Patha-Shilpo/
├── pathashilpo_backend/     FastAPI · AI orchestration, sync, API-key custody
│   ├── app/
│   │   ├── api/v1/endpoints/    AI + domain routes
│   │   ├── core/                config, security
│   │   ├── schemas/             Pydantic models
│   │   └── services/            Gemini · fal.ai · Sarvam · Bhashini · Firebase
│   ├── functions/           Firebase Cloud Functions (TypeScript)
│   └── sync/                Server-side conflict resolution & idempotency
│
├── pathashilpo_frontend/    Flutter · one binary, dual shells (seller + buyer)
│   ├── assets/data/             Fonts + offline price medians
│   └── lib/
│       ├── ai/                  Image · voice · listing · pricing · TTS routers
│       ├── core/                Theme · i18n · routing · shared widgets
│       ├── data/                Models · Hive boxes · Firebase services
│       ├── features/            auth · seller · buyer
│       └── sync/                Offline queue, backoff, conflict resolution
│
├── AI_COWORKER/             Multi-agent dev workflow + shared memory (git-ignored)
└── PRD.md · TRD.md · PROJECT_CONTEXT.md
```

---

## Architecture at a glance

```
┌─────────────┐  phone OTP   ┌──────────────────┐
│   ARTISAN   │─────────────►│    FIREBASE      │
│  (Android)  │◄────────────►│  Auth            │
└─────────────┘  Firestore   │  Firestore       │
┌─────────────┐   Storage    │  Cloud Storage   │
│    BUYER    │◄────────────►│  (Rules = RBAC)  │
│  (Android)  │              └──────────────────┘
└─────────────┘                       ▲
       │                              │ Admin SDK
       │ HTTPS               ┌────────┴─────────┐
       ▼                     │  CLOUD FUNCTIONS │
┌──────────────────┐         │  (TypeScript)    │
│  FASTAPI BACKEND │◄───────►│  auth triggers   │
│  (Render)        │         │  AI proxies      │
│  AI orchestration│         └──────────────────┘
│  sync engine     │
└──────────────────┘
       │ HTTPS
       ▼
┌──────────────────────────────────────────────┐
│  Gemini · Sarvam AI · Bhashini ULCA · fal.ai │
└──────────────────────────────────────────────┘
```

**Every AI key lives server-side.** The client authenticates to the backend with a Firebase ID token; no provider key ever ships in the APK.

### Every pipeline has an offline twin

| Pipeline | Online | Offline |
| :--- | :--- | :--- |
| Image | fal.ai `birefnet` → `clarity-upscaler` | Laplacian quality check + crop/pad |
| Speech | Sarvam AI → Bhashini ULCA | Device ASR → record + guided form |
| Listing | Gemini 2.0 Flash | Keyword spotting + ARB template |
| Pricing | Deterministic formula | **Identical** deterministic formula |

The router never throws to the UI. The artisan is never blocked.

---

## Fair pricing, in the open

```
floor     = (materialCost + hours × ₹150) × 1.15
suggested = round(floor × 1.25, ₹50)
max       = round(suggested × 1.30, ₹50)
```

Identical online and offline, and always explained aloud in Hindi. **The artisan may override any price, and a confirmed price is never overwritten by the server.**

---

## Getting started

### Backend

```bash
cd pathashilpo_backend
python -m venv .venv && source .venv/Scripts/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env                                     # fill in the API keys you have
uvicorn app.main:app --reload --port 8000
```

Then check `http://127.0.0.1:8000/health` and the interactive docs at `/docs`.

The AI endpoints degrade gracefully with **no** keys configured — useful for local work:

```bash
# Returns a template-generated listing when GEMINI_API_KEY is absent
curl -X POST http://127.0.0.1:8000/api/v1/ai/listing \
  -H "Authorization: Bearer dev-token" -H "Content-Type: application/json" \
  -d '{"transcript":"yeh chanderi saree hai","craft_type":"saree","material":"silk","hours_of_work":6}'
```

### Frontend

```bash
cd pathashilpo_frontend
flutter pub get
flutter run
```

> ⚠️ Not yet runnable — `pubspec.yaml` has not been authored and the Dart sources are empty placeholders. See **Status** below.

---

## Environment variables

Backend (`pathashilpo_backend/.env`, and Render env vars in production):

| Variable | Purpose |
| :--- | :--- |
| `GEMINI_API_KEY` | Listing generation |
| `SARVAM_API_KEY` | Primary Indic ASR / TTS / translate |
| `BHASHINI_API_KEY`, `BHASHINI_USER_ID` | Fallback Indic ASR (ULCA) |
| `FAL_KEY` | Background removal + enhancement |
| `FIREBASE_SERVICE_ACCOUNT`, `FIREBASE_PROJECT_ID` | Firebase Admin SDK |
| `ENV`, `PORT`, `CORS_ORIGINS` | App configuration |

`.env` is git-ignored; `.env.example` is committed as the template.

---

## Status

| Area | State |
| :--- | :--- |
| Backend — AI layer (`/ai/listing`, `/ai/image`, `/ai/voice`, `/health`) | ✅ Built and verified |
| Backend — auth | ⚠️ **Stubbed** — any bearer token is accepted; not deploy-safe |
| Backend — sync, products, enquiries, RFQ, Firestore rules | ❌ Not started |
| Frontend — Flutter app | 🔴 Blocked — no `pubspec.yaml`, sources empty |
| Web — marketing site | ❌ Not started |

Full detail in [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) §8.

### Known issues

- **Backend auth is a stub.** `app/core/security.py` does not call `firebase_admin.auth.verify_id_token()`. Must be replaced before deployment, and there is no rate limiting yet.
- **The bundled fonts cannot render Hindi.** All seven supplied OTFs (Kalam, Lora, Rowan) are Latin-only — zero Devanagari glyphs. Every `TextStyle` must declare `fontFamilyFallback` to the system Noto faces, and this must be confirmed on a real device before the demo.
- **Two divergent design systems** exist — one for the app, one for the marketing site. See `PROJECT_CONTEXT.md` §10.

---

## Target device

Android 8.0 (API 26) · 2 GB RAM · 720×1280 · intermittent 2G/3G. **All performance budgets are stated against this device, not a flagship.** APK target ≤ 40 MB, which is why no ML models are bundled in the MVP.

---

## The demo

1. Open the app → choose "I make things"
2. **Turn on airplane mode**
3. Photograph the saree → speak in Hindi → enter cost and hours
4. A complete listing appears, priced, with an **"Offline Draft"** badge
5. Restore the network → the badge syncs → the photo sharpens, the copy improves, **the price does not change**
6. Switch to buyer mode → find the product → read the maker's story → send an enquiry

Step 2 is the moment that wins it.

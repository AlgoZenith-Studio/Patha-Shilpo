# PATHASHILPA — TECHNICAL REQUIREMENTS DOCUMENT

**Version** 3.0 — full product architecture **and** MVP build scope
**Companion to** [`PRD.md`](PRD.md) (product) · [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) (single source of truth) · [`README.md`](README.md) (repo overview)
**Audience** engineers building the system

---

# 1 · PURPOSE & SCOPE

This document specifies **how** the system is built: architecture, schemas, contracts, algorithms, security rules, budgets and test criteria. Product rationale lives in the PRD and is not repeated here.

This TRD covers **two tiers at once**:

- **The full product** — the complete target architecture Pathashilpa is designed to become. Every subsystem here has a committed technical design, so nothing built for the MVP has to be thrown away later.
- **The MVP** — the subset actually being built now. Everything outside it is designed but not implemented.

## 1.1 Scope legend

Used throughout this document:

| Marker | Meaning |
|---|---|
| 🟢 **MVP** | In the MVP build. Fully implemented. |
| 🟡 **MVP-partial** | In the MVP, but mocked, stubbed or degraded — and labelled as such in the UI. |
| 🔵 **Post-MVP** | Designed in this document (§19), deliberately not built yet. |

## 1.2 Scope matrix

| Subsystem | MVP | Full product | Where specified |
|---|---|---|---|
| Flutter client, dual role shells | 🟢 | same | §11 |
| FastAPI backend, AI orchestration | 🟢 | + horizontal scaling, queue workers | §6, §19.10 |
| Firebase Auth / Firestore / Storage | 🟢 | same | §4, §5 |
| Cloud Functions (auth triggers, AI proxies) | 🟢 | + event fan-out, scheduled jobs | §6.2 |
| Offline engine & idempotent sync | 🟢 | same — this is the product thesis | §9 |
| Image pipeline | 🟢 fal.ai online + crop/pad offline | + on-device TFLite matting | §8.4, §19.2 |
| Speech pipeline | 🟢 Sarvam→Bhashini→device ASR | + on-device Vosk, all 22 languages | §8.2–8.3, §19.1, §19.3 |
| Listing generation | 🟢 Gemini + offline template | + image-conditioned generation | §8.1, §19.4 |
| Pricing engine | 🟢 deterministic formula | + ML market band on realised sales | §17.4, §19.5 |
| Discovery & search | 🟢 tag `array-contains-any` | + embeddings and vector search | §19.6 |
| Moderation & provenance | 🟡 flag field + stub screen | + perceptual-hash dedup, review queue | §19.7 |
| RBAC — 4 roles in rules | 🟢 rules real, 2 roles in UI | + full moderator and dept tooling | §5.2, §19.8 |
| KYC / artisan verification | 🟡 document upload, unverified | + real verification workflow | §19.8 |
| GeM / ONDC publishing | 🟡 mocked status chip | + real catalog and order sync | §19.9 |
| Payments, escrow, settlement | ⬜ absent | + full order and payment rails | §19.9 |
| Credit scoring, export enablement | ⬜ absent | + designed on sales history | §19.11 |
| Observability | 🟡 Hive ring buffer, no SDK | + crash reporting, metrics, tracing | §13.2, §19.12 |
| React marketing site | 🟢 | same | §11.6 |

**MVP hard boundary:** anything requiring a **bundled ML model** is out (breaks the ≤ 40 MB APK budget, §12), and anything requiring **money to move** is out (payments, escrow, settlement).

---

# 2 · SYSTEM ARCHITECTURE

## 2.1 Context

```
┌─────────────┐   phone OTP    ┌──────────────────┐
│   ARTISAN   │───────────────►│                  │
│  (Android)  │◄──────────────►│    FIREBASE      │
└─────────────┘   Firestore    │  Auth            │
                   Storage     │  Firestore       │
┌─────────────┐                │  Cloud Storage   │
│    BUYER    │◄──────────────►│  (Rules = RBAC)  │
│  (Android)  │                └──────────────────┘
└─────────────┘                         ▲
       │                                │ Admin SDK
       │ HTTPS                 ┌────────┴─────────┐
       ▼                       │  CLOUD FUNCTIONS  │
┌──────────────────┐           │  (TypeScript)     │
│  FASTAPI BACKEND │◄─────────►│  auth triggers    │
│  (Render)        │           │  AI proxies       │
│  AI orchestration│           └──────────────────┘
│  sync engine     │
│  business logic  │                    ▲
└──────────────────┘                    │ read-only
       │ HTTPS                 ┌────────┴─────────┐
       ▼                       │   REACT WEB      │
┌──────────────────┐           │  (Vercel)        │
│  AI PROVIDERS    │           └──────────────────┘
│  Gemini API      │
│  Bhashini / ULCA │
│  Sarvam AI       │
│  fal.ai          │
└──────────────────┘
```

## 2.2 Containers

| Container | Runtime | Responsibility |
|---|---|---|
| `pathashilpa_app` | Flutter / Android | UI, on-device AI, offline store, sync engine, SDK + HTTPS calls to backend |
| `pathashilpo_backend` | FastAPI on Render (Docker) | AI orchestration, sync endpoint, business logic, API key custody |
| Cloud Functions | Firebase (TypeScript) | auth triggers (`on_user_created`), AI proxy fallbacks, event-driven logic |
| Firebase Auth | managed | identity, phone OTP, custom claims |
| Cloud Firestore | managed | system of record |
| Cloud Storage | managed | images, audio |
| Gemini API | external | listing generation (proxied via backend) |
| Bhashini / ULCA | external | ASR, MT, TTS (proxied via backend) |
| Sarvam AI | external | ASR, TTS, translation (proxied via backend) |
| fal.ai | external | image processing, background removal (proxied via backend) |
| `pathashilpa_web` | Vite/React on Vercel | marketing site, read-only Firestore |

## 2.3 Architectural decisions

| # | Decision | Rationale | Rejected alternative |
|---|---|---|---|
| AD-1 | **FastAPI backend on Render** | Centralises API key custody, AI orchestration, and sync logic; keys never ship in APK | Firebase-only — exposes API keys in APK, no server-side validation |
| AD-2 | **AI calls server-side via FastAPI** | Gemini/Bhashini/Sarvam/fal keys stay on the server; client sends data to `/api/v1/` endpoints | Client-side AI calls — key in APK, quota abuse risk |
| AD-3 | One app, role switch | ~30% extra code vs 100% for a second app | Two Flutter apps |
| AD-4 | Hive over SQLite | Key-value fits draft objects; zero schema migration cost | Drift/SQLite |
| AD-5 | Router pattern for every AI service | Offline parity is the product thesis | Try/catch fallbacks scattered in UI |
| AD-6 | Deterministic pricing, no ML | Explainable, identical offline, zero training data | LightGBM — no dataset exists yet |
| AD-7 | Cloud Functions for triggers, FastAPI for requests | Cloud Functions handle Firebase events (user creation, custom claims); FastAPI handles client-initiated AI/sync work | All Cloud Functions — cold starts on every AI call |
| AD-8 | Sarvam AI as Bhashini alternative | Sarvam provides reliable Indic speech/translation; can swap with Bhashini per availability | Bhashini-only — single point of failure for speech |
| AD-9 | fal.ai for image processing | Hosted image models (background removal, enhancement) without self-managing GPU infra | On-device TFLite — APK size, device constraints |

---

# 3 · TECHNOLOGY STACK

## 3.1 Flutter — pinned dependencies

```yaml
environment: { sdk: '>=3.5.0 <4.0.0' }

dependencies:
  flutter: { sdk: flutter }
  flutter_localizations: { sdk: flutter }

  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_storage: ^12.3.4

  hive: ^2.2.3
  hive_flutter: ^1.1.0

  image_picker: ^1.1.2
  image: ^4.2.0                # decode, crop, pad, compress
  speech_to_text: ^7.0.0
  flutter_tts: ^4.2.0
  permission_handler: ^11.3.1

  dio: ^5.7.0
  connectivity_plus: ^6.0.5
  uuid: ^4.5.1
  intl: ^0.19.0
  provider: ^6.1.2
  google_fonts: ^6.2.1
  cached_network_image: ^3.4.1

dev_dependencies:
  build_runner: ^2.4.13
  hive_generator: ^2.0.1
  flutter_lints: ^5.0.0

flutter:
  generate: true               # enables gen_l10n
```

## 3.2 Web

```
react ^18 · react-dom ^18 · react-router-dom ^6
typescript ^5 · vite ^5
tailwindcss ^3 · postcss · autoprefixer
lucide-react · firebase ^10 (read-only)
```

## 3.3 FastAPI backend — Python

```
# requirements.txt
fastapi>=0.115.0
uvicorn[standard]>=0.32.0
pydantic>=2.9.0
pydantic-settings>=2.5.0

# Firebase Admin
firebase-admin>=6.5.0

# AI services
google-generativeai>=0.8.0       # Gemini
httpx>=0.27.0                    # Bhashini, Sarvam, fal.ai HTTP calls
fal-client>=0.5.0                # fal.ai SDK

# Utilities
python-multipart>=0.0.12         # file uploads
python-jose[cryptography]>=3.3.0 # JWT verification
Pillow>=10.4.0                   # server-side image processing
```

## 3.4 Cloud Functions — TypeScript

```
# functions/package.json
firebase-functions ^5
firebase-admin ^12
typescript ^5
```

## 3.5 Target device baseline

Android 8.0 (API 26) · 2 GB RAM · quad-core ~1.4 GHz · 720×1280 · 2G/3G intermittent.
**All performance budgets in §11 are stated against this device, not a flagship.**

---

# 4 · DATA ARCHITECTURE

## 4.1 Firestore collections

### `users/{uid}`
| Field | Type | Notes |
|---|---|---|
| `uid` | string | == doc id |
| `role` | string | `artisan` \| `buyer` \| `moderator` \| `dept` — **immutable after first write** |
| `phone` | string | E.164 |
| `locale` | string | `en` \| `hi` \| `bn` |
| `createdAt` | timestamp | server |
| `lastSeenAt` | timestamp | server |

### `artisans/{uid}`
| Field | Type | Notes |
|---|---|---|
| `name`, `nameHi` | string | |
| `village`, `district`, `state` | string | |
| `craft` | string | from `constants/crafts.dart` |
| `cluster` | string | |
| `giTag` | string? | null if none |
| `story`, `storyHi` | string | ≤ 400 chars |
| `yearsOfPractice` | int | |
| `photoUrl` | string? | |
| `verified` | bool | default false; moderator-writable only |
| `productCount` | int | denormalised counter |
| `createdAt`, `updatedAt` | timestamp | |

### `buyers/{uid}`
`name`, `phone`, `email?`, `buyerType` (`retail`\|`b2b`\|`exporter`\|`govt`), `company?`, `gstin?`, `interests[]`, `states[]`, `savedProducts[]`, `createdAt`

### `products/{productId}`
| Field | Type | Notes |
|---|---|---|
| `productId` | string | == doc id |
| `localId` | string | client UUID — **idempotency key** |
| `artisanId` | string | owner uid |
| `imageUrl` | string? | processed |
| `originalImageUrl` | string? | raw |
| `title`, `titleHi` | string | ≤ 70 chars |
| `description`, `descriptionHi` | string | ≤ 600 chars |
| `tags` | string[] | 6–8, lowercase |
| `material`, `craftType` | string | |
| `colors` | string[] | |
| `hoursOfWork` | int | |
| `materialCost` | int | ₹ |
| `priceFloor`, `priceSuggested`, `priceMax`, `priceFinal` | int | ₹ |
| `priceReasoning`, `priceReasoningHi` | string | |
| `state` | string | see §8.1 |
| `status` | string | `draft` \| `live` \| `flagged` \| `sold` |
| `channels` | string[] | `["storefront"]`, GeM/ONDC mocked |
| `transcript` | string | raw ASR text |
| `speechTier` | int | 1\|2\|3 |
| `generatedBy` | string | `gemini` \| `template` |
| `perceptualHash` | string? | stub |
| `flagged` | bool | moderator only |
| `createdAt`, `updatedAt`, `syncedAt` | timestamp | |

### `enquiries/{enquiryId}`
`productId`, `artisanId`, `buyerUid`, `buyerName`, `buyerPhone`, `buyerType`, `quantity`, `message`, `status` (`new`\|`accepted`\|`declined`), `createdAt`

### `rfqs/{rfqId}`
`buyerUid`, `craft`, `cluster?`, `quantity`, `deadline`, `budgetMin`, `budgetMax`, `matchedArtisanIds[]`, `status`, `createdAt`

## 4.2 Required composite indexes

```
products : status ASC, createdAt DESC
products : artisanId ASC, createdAt DESC
products : craftType ASC, status ASC, priceFinal ASC
products : tags ARRAY, status ASC, createdAt DESC
enquiries: artisanId ASC, status ASC, createdAt DESC
enquiries: buyerUid ASC, createdAt DESC
```

## 4.3 Cloud Storage layout

```
/products/{artisanId}/{localId}/original.jpg     ≤ 1.5 MB
/products/{artisanId}/{localId}/processed.jpg    ≤ 300 KB
/products/{artisanId}/{localId}/audio.m4a        ≤ 100 KB
/artisans/{uid}/profile.jpg                      ≤ 200 KB
```

## 4.4 Hive boxes

| Box | Key | Value |
|---|---|---|
| `session` | fixed keys | uid, role, locale, lastSyncAt |
| `drafts` | `localId` | full Product map |
| `queue` | autoIncrement | `{op, localId, attempts, nextAttemptAt}` |
| `cache_products` | `productId` | Product map (buyer browse cache) |
| `cache_medians` | `craftType` | `{min, median, max}` |
| `media` | `localId` | `{imagePath, audioPath}` |

---

# 5 · SECURITY

## 5.1 Auth flow

```
1  User enters phone → firebase_auth.verifyPhoneNumber
2  OTP → signInWithCredential → uid issued
3  If users/{uid} absent → role_select_screen
4  Client writes users/{uid} with chosen role  (create-only)
5  Cloud Function on_user_created sets custom claim { role }
6  Role mirrored into session box for shell selection
7  All backend requests carry Firebase ID token in Authorization header
8  FastAPI verifies token via firebase_admin.auth.verify_id_token()
```

## 5.2 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {

    function signedIn()  { return request.auth != null; }
    function uid()       { return request.auth.uid; }
    function role()      { return get(/databases/$(db)/documents/users/$(uid())).data.role; }
    function isArtisan() { return signedIn() && role() == 'artisan'; }
    function isBuyer()   { return signedIn() && role() == 'buyer'; }
    function isMod()     { return signedIn() && role() == 'moderator'; }
    function isDept()    { return signedIn() && role() == 'dept'; }

    match /users/{userId} {
      allow read:   if uid() == userId || isMod();
      allow create: if uid() == userId
                    && request.resource.data.role in ['artisan','buyer'];
      allow update: if uid() == userId
                    && request.resource.data.role == resource.data.role;   // role immutable
      allow delete: if false;
    }

    match /artisans/{aid} {
      allow read:  if true;
      allow write: if uid() == aid && isArtisan();
      allow update: if isMod()
                    && request.resource.data.diff(resource.data)
                       .affectedKeys().hasOnly(['verified']);
    }

    match /buyers/{bid} {
      allow read, write: if uid() == bid && isBuyer();
    }

    match /products/{pid} {
      allow read: if resource.data.status == 'live'
                  || uid() == resource.data.artisanId
                  || isMod();
      allow create: if isArtisan()
                    && request.resource.data.artisanId == uid()
                    && request.resource.data.localId is string;
      allow update: if uid() == resource.data.artisanId
                    && request.resource.data.artisanId == resource.data.artisanId;
      allow delete: if uid() == resource.data.artisanId;
      allow update: if isMod()
                    && request.resource.data.diff(resource.data)
                       .affectedKeys().hasOnly(['flagged','flagReason','status']);
    }

    match /enquiries/{eid} {
      allow create: if isBuyer() && request.resource.data.buyerUid == uid();
      allow read:   if uid() == resource.data.buyerUid
                    || uid() == resource.data.artisanId;
      allow update: if uid() == resource.data.artisanId
                    && request.resource.data.diff(resource.data)
                       .affectedKeys().hasOnly(['status']);
      allow delete: if false;
    }

    match /rfqs/{rid} {
      allow create: if isBuyer();
      allow read:   if isBuyer() || isArtisan();
      allow update, delete: if uid() == resource.data.buyerUid;
    }

    match /analytics/{doc=**} {
      allow read:  if isDept() || isMod();
      allow write: if false;
    }
  }
}
```

## 5.3 Storage Rules

```javascript
service firebase.storage {
  match /b/{bucket}/o {
    match /products/{artisanId}/{allPaths=**} {
      allow read:  if true;
      allow write: if request.auth.uid == artisanId
                   && request.resource.size < 2 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*|audio/.*');
    }
    match /artisans/{uid}/{allPaths=**} {
      allow read:  if true;
      allow write: if request.auth.uid == uid
                   && request.resource.size < 500 * 1024;
    }
  }
}
```

## 5.4 Key management

| Key | Storage | Exposure |
|---|---|---|
| Firebase config | `google-services.json` | public by design; Rules are the control |
| `GEMINI_API_KEY` | **Render environment variable** | server-only, never in APK |
| `BHASHINI_API_KEY` | **Render environment variable** | server-only |
| `BHASHINI_USER_ID` | **Render environment variable** | server-only |
| `SARVAM_API_KEY` | **Render environment variable** | server-only |
| `FAL_KEY` | **Render environment variable** | server-only |
| `FIREBASE_SERVICE_ACCOUNT` | **Render environment variable** | JSON key for firebase-admin |

**All AI and service keys live exclusively on the backend.** The client authenticates to the backend via Firebase ID tokens. This resolves the APK key-exposure risk that existed in the previous architecture.

## 5.5 Backend authentication

Every FastAPI endpoint (except health check) requires a valid Firebase ID token:

```
Authorization: Bearer <firebase_id_token>
```

The `core/security.py` module verifies the token using `firebase_admin.auth.verify_id_token()`, extracts `uid` and custom claims, and injects the authenticated user into request handlers.

## 5.6 Privacy

- Voice audio uploaded only on sync; artisan can delete any product and its media
- No Aadhaar number is ever stored — documents are images only, unverified in MVP
- PII fields: `phone`, `name`, `village`, `photoUrl`. No location tracking, no analytics SDK
- Data deletion: delete `artisans/{uid}` + `users/{uid}` + all owned products and Storage paths

---

# 6 · BACKEND STRUCTURE — `pathashilpo_backend/`

```
pathashilpo_backend/
├── app/
│   ├── __init__.py
│   ├── main.py                        FastAPI application entry point
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py                  Settings (env vars, defaults)
│   │   └── security.py               Firebase token verification, auth dependencies
│   ├── api/
│   │   ├── __init__.py
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── api.py                 v1 router aggregator
│   │       └── endpoints/
│   │           ├── __init__.py
│   │           ├── auth.py            token verify, role check
│   │           ├── products.py        product CRUD (via Firestore)
│   │           ├── enquiries.py       enquiry management
│   │           ├── rfq.py             RFQ create/match
│   │           ├── sync.py            offline → server sync endpoint
│   │           ├── voice_ai.py        speech-to-text (Bhashini/Sarvam)
│   │           ├── listing_ai.py      listing generation (Gemini)
│   │           └── image_ai.py        image processing (fal.ai)
│   ├── db/
│   │   └── __init__.py                Firestore client initialisation
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── user.py                    User/Artisan/Buyer Pydantic models
│   │   ├── artisan.py
│   │   ├── buyer.py
│   │   ├── product.py                 Product request/response schemas
│   │   ├── enquiry.py
│   │   ├── rfq.py
│   │   └── ai.py                      AI request/response schemas
│   └── services/
│       ├── __init__.py
│       ├── firebase_service.py        Firebase Admin SDK wrapper (Firestore, Auth, Storage)
│       ├── gemini_service.py          Gemini API client
│       ├── bhashini_service.py        Bhashini ULCA ASR/MT/TTS client
│       ├── sarvam_service.py          Sarvam AI ASR/TTS/translate client
│       └── fal_service.py             fal.ai image processing client
│
├── models/                            TypeScript type definitions (shared with functions)
│   ├── user.model.ts
│   ├── artisan.model.ts
│   ├── buyer.model.ts
│   ├── product.model.ts
│   ├── enquiry.model.ts
│   └── rfq.model.ts
│
├── functions/                         Firebase Cloud Functions
│   ├── package.json
│   ├── tsconfig.json
│   └── src/
│       ├── index.ts                   function exports
│       ├── auth/
│       │   └── on_user_created.ts     set custom claims on signup
│       └── ai/
│           ├── gemini_proxy.ts        callable function fallback
│           ├── sarvam_proxy.ts        callable function fallback
│           └── fal_ai_proxy.ts        callable function fallback
│
├── rbac/
│   └── dept.rules                     dept-role specific rule definitions
│
├── sync/                              Server-side sync logic (TypeScript, used by functions)
│   ├── conflict_resolver.ts           server-wins merge strategy
│   ├── idempotency_guard.ts           localId dedup enforcement
│   └── queue_worker.ts                server-side queue processing
│
├── firestore.rules                    Firestore security rules (deployable)
├── firestore.indexes.json             composite index definitions
├── storage.rules                      Cloud Storage security rules
│
├── Dockerfile                         backend container image
├── docker-compose.yml                 local development compose
├── render.yaml                        Render deployment config
└── requirements.txt                   Python dependencies
```

## 6.1 FastAPI endpoint contracts

Build status is live as of §18. All routes except `/health` require a Firebase ID token (§5.5).

| Endpoint | Scope | Built |
|---|---|---|
| `GET  /health` | 🟢 MVP | ✅ |
| `POST /api/v1/ai/listing` | 🟢 MVP | ✅ |
| `POST /api/v1/ai/image` | 🟢 MVP | ✅ |
| `POST /api/v1/ai/voice` | 🟢 MVP | ✅ |
| `POST /api/v1/auth/verify` | 🟢 MVP | ❌ |
| `POST /api/v1/sync` | 🟢 MVP | ❌ |
| `GET  /api/v1/products` | 🟢 MVP | ❌ |
| `POST /api/v1/enquiries` | 🟢 MVP | ❌ |
| `GET`·`POST /api/v1/rfqs` | 🟢 MVP | ❌ |
| `/api/v1/orders/*` | 🔵 Post-MVP | — (§19.9) |
| `/api/v1/channels/*` (GeM/ONDC) | 🔵 Post-MVP | — (§19.9) |
| `/api/v1/search` (vector) | 🔵 Post-MVP | — (§19.6) |
| `/api/v1/moderation/*` | 🔵 Post-MVP | — (§19.7) |

### `POST /api/v1/auth/verify`
Verifies Firebase ID token, returns user profile and role.

### `POST /api/v1/ai/voice`
Accepts audio (base64 or multipart), source language. Routes through Sarvam → Bhashini fallback. Returns transcript, confidence, tier.

### `POST /api/v1/ai/listing`
Accepts transcript, craft metadata. Calls Gemini for structured listing generation. Returns title, description, tags in EN + HI.

### `POST /api/v1/ai/image`
Accepts image (multipart). Calls fal.ai for background removal and enhancement. Returns processed image URL, quality score.

### `POST /api/v1/sync`
Accepts full product draft payload (JSON + media references). Orchestrates: validate → write Firestore doc (upsert on `localId`) → upload media → request AI upgrade → set LIVE. Returns sync result with updated product state.

> 🔵 In the full product this returns as soon as the document is durable, handing the AI upgrade to a background worker rather than holding the request open — see §19.10.

### `GET /api/v1/products`
Paginated product listing with filters (craft, status, price range, tags). Reads from Firestore.

### `POST /api/v1/enquiries`
Creates an enquiry on a product. Validates buyer role.

### `GET /api/v1/rfqs` · `POST /api/v1/rfqs`
RFQ listing and creation. 🟡 MVP saves the form but performs no matching; semantic matching is §19.6.

## 6.2 Cloud Functions

| Function | Trigger | Purpose |
|---|---|---|
| `onUserCreated` | `auth.user().onCreate` | Sets custom claims `{ role }` from `users/{uid}.role` document |
| `geminiProxy` | `onCall` | Fallback callable for Gemini if FastAPI is unreachable |
| `sarvamProxy` | `onCall` | Fallback callable for Sarvam if FastAPI is unreachable |
| `falAiProxy` | `onCall` | Fallback callable for fal.ai if FastAPI is unreachable |

Cloud Functions serve as **fallback proxies** — the Flutter app tries the FastAPI backend first, falls to Cloud Functions on failure, then to on-device processing as a last resort.

---

# 7 · SERVICE CONTRACTS (client-internal)

Every AI service follows the same shape.

```dart
abstract class ImageService  { Future<ImageResult>   process(ImageInput i); }
abstract class SpeechService { Future<SpeechResult>  transcribe(SpeechInput i); }
abstract class ListingService{ Future<ListingResult> generate(ListingInput i); }
abstract class PricingService{ PriceResult           compute(PriceInput i); }
abstract class TtsService    { Future<void>          speak(String text, String locale); }
```

### Result types

```dart
class ImageResult {
  String localPath; String? remoteUrl;
  double qualityScore;          // 0..1
  bool backgroundRemoved;
  ProcessingTier tier;          // online | offline
}

class SpeechResult {
  String transcript; String languageCode;
  double confidence; String? audioPath;
  int tier;                     // 1 sarvam/bhashini | 2 device | 3 record-only
}

class ListingResult {
  String title, titleHi, description, descriptionHi;
  List<String> tags, colors;
  String material, craftType;
  String generatedBy;           // gemini | template
}

class PriceResult {
  int floor, suggested, max;
  String reasoning, reasoningHi;
  String source;                // live | cached
}
```

**Router contract:** `XRouter.run()` must never throw to the UI. On total failure it returns the offline implementation's result with a degraded flag. The UI renders the same widgets either way.

### Client-side AI call chain

```
TIER 1  FastAPI backend         online · full AI pipeline
   │    POST /api/v1/ai/*
   │    fails or timeout ↓
TIER 2  Cloud Function          online · callable fallback
   │    fails or offline ↓
TIER 3  ON-DEVICE               offline · deterministic fallback
        template listing, device ASR, crop/pad
```

---

# 8 · EXTERNAL API CONTRACTS (backend-side)

All external AI calls are made **from the FastAPI backend**, never from the client.

## 8.1 Gemini — listing generation (`gemini_service.py`)

```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent
     ?key={GEMINI_API_KEY}
Content-Type: application/json

{
  "contents":[{"parts":[{"text":"<prompt>"}]}],
  "generationConfig":{
    "temperature":0.4,
    "maxOutputTokens":800,
    "responseMimeType":"application/json"
  }
}
```

**Response handling**
- Strip markdown fences defensively even with `responseMimeType` set
- Validate all nine keys present; any missing → fall back to template
- Timeout **12 s**; one retry; then template
- 🟢 Never send the image to Gemini in MVP — text only, keeps latency and cost down. 🔵 Image-conditioned generation is §19.4

## 8.2 Bhashini (ULCA) — ASR (`bhashini_service.py`)

```
1  POST /ulca/apis/v0/model/getModelsPipeline    → pipeline config + callback URL
     headers: userID, ulcaApiKey
2  POST {callbackUrl}                            → compute
     headers: {inferenceApiKey.name}: {value}
     body: audioContent (base64), sourceLanguage
```

Timeout **10 s** → fall to Sarvam or device ASR. Cache the pipeline config for the session; do not re-fetch per call.

## 8.3 Sarvam AI — ASR/TTS/Translate (`sarvam_service.py`)

```
POST https://api.sarvam.ai/speech-to-text
     headers: api-subscription-key: {SARVAM_API_KEY}
     body: audio (base64), language_code

POST https://api.sarvam.ai/text-to-speech
     headers: api-subscription-key: {SARVAM_API_KEY}
     body: text, language_code, speaker

POST https://api.sarvam.ai/translate
     headers: api-subscription-key: {SARVAM_API_KEY}
     body: input, source_language, target_language
```

Timeout **10 s**. Sarvam is the **primary** speech provider; Bhashini serves as fallback for languages Sarvam doesn't cover well.

## 8.4 fal.ai — image processing (`fal_service.py`)

```
POST https://queue.fal.run/fal-ai/birefnet     (background removal)
     headers: Authorization: Key {FAL_KEY}
     body: { image_url | image (base64) }

POST https://queue.fal.run/fal-ai/clarity-upscaler   (enhancement, optional)
     headers: Authorization: Key {FAL_KEY}
     body: { image_url }
```

fal.ai uses an async queue model: submit → poll status → retrieve result. Timeout **30 s** total. On failure, return original image with `backgroundRemoved: false`.

## 8.5 Failure matrix

| Service | Timeout | Retry | Fallback |
|---|---|---|---|
| Gemini (via FastAPI) | 12 s | 1 | template listing |
| Sarvam ASR (via FastAPI) | 10 s | 0 | Bhashini ASR |
| Bhashini ASR (via FastAPI) | 10 s | 0 | device ASR |
| Sarvam/Bhashini TTS | 8 s | 0 | flutter_tts |
| fal.ai image (via FastAPI) | 30 s | 1 | crop/pad only |
| FastAPI (from client) | 15 s | 0 | Cloud Function callable |
| Cloud Function (from client) | 10 s | 0 | on-device fallback |
| Firestore write | SDK default | SDK offline persistence | Hive queue |
| Storage upload | 60 s | 3, backoff | stay queued |

---

# 9 · OFFLINE & SYNC ENGINE

## 9.1 Product state machine

```
CAPTURED
   │ local processing completes
   ▼
OFFLINE_PROCESSED   ← artisan can sell from here; listing is complete
   │ connectivity restored && queue reached this item
   ▼
SYNCING
   │ upload media → write doc → request AI upgrade (via FastAPI /sync)
   ▼
AI_UPGRADED
   │ status set live
   ▼
LIVE
```

Any transition may fail → return to `OFFLINE_PROCESSED`, increment attempts, requeue. **No state is terminal-on-error.**

## 9.2 Idempotency

- `localId` = UUID v4 generated at capture, never regenerated
- Server document id **is** the `localId` → repeated writes upsert, never duplicate
- Storage paths keyed by `localId` → re-upload overwrites
- `idempotency_guard.ts` enforces this on the server side

## 9.3 Queue algorithm

```
loop while online && queue not empty:
    item = queue.peek()
    if now < item.nextAttemptAt: sleep; continue
    try:
        POST /api/v1/sync with full product payload
        (backend handles: validate → upload media → write Firestore → AI upgrade)
        state = LIVE
        queue.pop()
    catch e:
        item.attempts += 1
        item.nextAttemptAt = now + min(2^attempts, 30) seconds
        if item.attempts > 8: mark item needs_attention, move to back
```

## 9.4 Conflict resolution

**Server wins** (`conflict_resolver.ts`), with one exception: `priceFinal` is artisan-authored and is never overwritten by a server-side recomputation. If a recomputed `priceSuggested` differs from the local one, the local value is retained and the difference logged — the artisan must never see the price change after they confirmed it.

## 9.5 Payload budget

| Item | Target | Method |
|---|---|---|
| processed.jpg | ≤ 300 KB | 1200×1200, JPEG q75 |
| original.jpg | ≤ 1.5 MB | uploaded last, lowest priority |
| audio.m4a | ≤ 100 KB | 16 kHz mono, 30 s cap |
| Firestore doc | ≤ 8 KB | text only |
| **Per product** | **≈ 400 KB** | excluding original |

---

# 10 · INTERNATIONALISATION

- `flutter_localizations` + `gen_l10n`; ARB files `app_en.arb`, `app_hi.arb`, `app_bn.arb`
- Resolution: `session.locale` → device locale → `en`
- **All artisan-facing primary buttons render English + Hindi simultaneously**, independent of locale
- `intl` for currency (`₹#,##,###` Indian grouping) and dates
- Speech locale is independent of UI locale — an artisan may run the UI in Hindi and speak Bundeli
- ARB keys namespaced: `artisan_*`, `buyer_*`, `common_*`, `error_*`

## 10.1 Typography & script coverage

Fonts supplied in `pathashilpo_frontend/assets/data/`:

| Role | Family | Files |
|---|---|---|
| Headings, AppBar | **Lora** | `Lora-Bold.otf` (w700), `Lora-SemiBold.otf` (w600) |
| Body, button labels, fields | **Kalam** | `Kalam-Regular.otf` (w400), `Kalam-Bold.otf` (w700) |
| Artisan stories, pull-quotes | **Rowan** | `Rowan-Medium.otf`, `Rowan-MediumItalic.otf`, `Rowan-SemiboldItalic.otf` |

**⚠ All three families are Latin-only.** Parsing each OTF `cmap` table yields 58 Latin glyphs and **zero** codepoints in U+0900–U+097F (Devanagari) or U+0980–U+09FF (Bengali). Naming any of them as `fontFamily` without mitigation renders every Hindi string as tofu boxes — which breaks the §10 bilingual-button rule outright.

**Required on every `TextStyle`:**

```dart
fontFamilyFallback: const ['Noto Sans Devanagari', 'Noto Sans Bengali', 'sans-serif'],
```

Android 8.0+ ships Noto, so this costs 0 MB against the §12 APK budget. Latin text keeps the brand fonts; Indic text falls through to the system face.

**Verification gate:** confirm on a physical device before the demo. If a target device lacks Noto Devanagari, a licensed Devanagari font must be bundled and the §12 APK budget re-checked.

---

# 11 · CLIENT ARCHITECTURE

## 11.1 Layers

```
features/  → widgets, screens, local state
   ↓ (never skips a layer)
ai/ · sync/ → service routers
   ↓
data/      → models, local boxes, remote services
   ↓
core/      → theme, i18n, rbac, config, utils
```

**Rule:** UI never imports `cloud_firestore` or `dio` directly.

## 11.2 State management

`provider` only. Three app-scoped providers:

| Provider | Holds |
|---|---|
| `AuthProvider` | uid, role, auth state stream |
| `ConnectivityProvider` | online bool, sync status |
| `LocaleProvider` | active locale |

Screen state stays local (`setState`) — no global store for the MVP.

## 11.3 Routing & RBAC guard

```
/                    splash → decides destination
/role-select         first login only
/login  /otp
/artisan/*           guard: role == artisan
/buyer/*             guard: role == buyer
/moderator/*         guard: role == moderator
/dept/*              guard: role == dept
```

Guard reads `AuthProvider.role`; on mismatch redirects to that role's home. **Cosmetic only — the authoritative check is §5.2.**

## 11.4 Add-product screen state

One `AddProductState` object held by the `PageView` parent:

```dart
class AddProductState {
  String localId;                  // set on entry
  File? photo; ImageResult? image;
  SpeechResult? speech;
  int? materialCost; int? hours;
  ListingResult? listing; PriceResult? price;
  bool wasOffline;
}
```

Persisted to Hive after every step so a crash or backgrounding never loses work.

## 11.5 Flutter structure — `pathashilpo_frontend/lib/`

**This reflects the actual on-disk tree and is authoritative.** Earlier drafts used `features/artisan/`, `lib/widgets/` and `ai/speech/`; the real structure uses `features/seller/`, `core/widgets/` and `ai/voice/`, with `controllers/`/`views/`/`models/` sub-layers under each AI pipeline.

```
lib/
├── main.dart                      entry point, Hive init, runApp
├── app.dart                       MaterialApp, theme, localization delegates
│
├── core/
│   ├── theme/                     colors.dart  app_theme.dart
│   ├── i18n/                      locale_provider.dart
│   │   └── l10n/                  app_en.arb  app_hi.arb  app_bn.arb
│   ├── routing/                   app_router.dart  route_names.dart
│   └── widgets/
│       ├── buttons/               primary_bilingual_button  voice_mic_button
│       ├── cards/                 craft_card  price_band_card
│       ├── badges/                offline_draft_badge  sync_indicator  provenance_tag
│       └── layout/                artisan_shell  buyer_shell
│
├── data/
│   ├── models/                    user  artisan  buyer  product  enquiry  rfq
│   ├── local/                     hive_init  session_box  drafts_box  queue_box
│   └── remote/                    auth_service  firestore_service  storage_service
│
├── ai/                            ← ALL PIPELINES LIVE HERE
│   ├── image/views/               image_capture_preview  quality_meter
│   ├── voice/views/               voice_recorder_widget  guided_fallback_form
│   ├── listing/views/             bilingual_listing_view
│   ├── pricing/
│   │   ├── controllers/           median_cache_service
│   │   └── views/                 price_band_slider_view
│   └── tts/
│       ├── controllers/           tts_router  tts_online_bhashini  tts_offline_flutter
│       ├── models/                tts_input
│       └── views/                 tts_readback_button
│
├── sync/                          sync_engine  connectivity_guard  conflict_resolver
│
└── features/
    ├── auth/
    │   ├── controllers/           auth_controller
    │   └── screens/               phone_login  otp_verify  role_select
    ├── seller/
    │   ├── onboarding/            artisan_onboarding_screen
    │   ├── profile/               artisan_profile_screen
    │   ├── products/              artisan_products_screen  artisan_product_detail_screen
    │   ├── enquiries/             artisan_enquiries_screen
    │   └── add_product/
    │       ├── step1_photo/       photo_capture_screen
    │       ├── step2_voice/       voice_record_screen
    │       ├── step3_costs/       cost_entry_screen
    │       └── step4_review/      pricing_review_screen
    └── buyer/
        ├── product/               buyer_product_detail_screen
        ├── profile/               buyer_profile_screen
        ├── enquiries/             buyer_enquiries_screen
        └── rfq/                   buyer_rfq_screen
```

Assets live in `pathashilpo_frontend/assets/data/` — the 7 OTF fonts (§10.1) and `medians.json`, the offline price-median cache.

> **Missing router implementations.** The `ai/` tree currently carries views and TTS controllers only. The `image_router` / `speech_router` / `listing_router` abstractions required by §7 and AD-5 have no files yet and must be added under each pipeline's `controllers/`.

## 11.6 React web structure — `pathashilpa_web/src/`

Not yet created. Target layout:

```
src/
├── main.tsx  App.tsx  index.css
├── pages/
│   ├── Home · HowItWorks · Pricing · ForArtisans · ForBuyers · About
│   ├── Press · PressArticle
│   ├── Privacy · Terms · RefundPolicy · ArtisanCharter · Contact
│   └── NotFound
├── components/
│   ├── layout/     Header  Footer  Container  Section
│   ├── ui/         Button  Card  Badge  Chip  Accordion  Stat
│   └── sections/   Hero  StatStrip  HowItWorksSteps  FeaturedArtisans
│                   ComparisonTable  FAQ  CTABand
├── data/           mockArticles  mockArtisans  faqs  stats  nav
├── lib/            firebase.ts (read-only)  cn.ts
└── types/          index.ts
```

Page-by-page content requirements are specified in `PRD.md` Part B (§12–§18).

---

# 12 · PERFORMANCE BUDGETS

Measured on the §3.5 baseline device.

| Operation | Budget |
|---|---|
| Cold start → first frame | ≤ 3.0 s |
| Camera open | ≤ 1.0 s |
| Image quality check | ≤ 300 ms |
| Crop + pad + compress | ≤ 1.5 s |
| Device ASR (10 s speech) | ≤ 2.0 s after stop |
| Backend AI round-trip (listing) | ≤ 8.0 s (15 s timeout) |
| Backend AI round-trip (image) | ≤ 15.0 s (30 s timeout) |
| Backend AI round-trip (voice) | ≤ 5.0 s (10 s timeout) |
| Price computation | ≤ 10 ms (pure arithmetic) |
| **Offline draft: photo → review screen** | **≤ 8 s total** |
| Sync one product on 3G (via /sync) | ≤ 30 s |
| Buyer grid, 20 items, cached | ≤ 1.5 s |

**APK size target:** ≤ 40 MB 🟢 (no bundled ML models in MVP).

> 🔵 This budget is the single constraint that keeps Vosk, MobileNetV3, CLIP and `u2netp` out of the MVP. Revisiting it is one deliberate decision, not four — see §19.3, which recommends dynamic feature delivery over simply raising the ceiling.

---

# 13 · ERROR HANDLING & OBSERVABILITY

## 13.1 Error taxonomy

| Class | Example | User-visible behaviour |
|---|---|---|
| Recoverable-silent | Gemini timeout via backend | template listing used; no message |
| Recoverable-informed | upload failed | "Will retry when connected" + retry button |
| User-actionable | photo too blurry | "Photo is blurry — take it again" + retake |
| Blocking | invalid OTP | inline field error |
| Fatal | Firebase init failure | error screen with restart |

**Rule:** the artisan never sees a technical error string. Every message is a plain sentence in their locale with one action.

## 13.2 Logging

`AppLogger` wrapper with levels. In debug, log to console; in release, log to a Hive ring buffer of the last 200 events, exportable from a hidden settings tap. 🟢 **No analytics SDK, no crash reporter in MVP** — a deliberate privacy choice, defensible in Q&A. 🔵 Opt-in telemetry and request tracing are §19.12; the §5.6 privacy posture constrains that permanently.

Backend logs via `uvicorn` structured logging to stdout (captured by Render).

---

# 14 · TESTING

| Layer | Coverage target | What |
|---|---|---|
| Unit | pricing, template listing, queue backoff, idempotency | ≥ 80% on `ai/` + `sync/` |
| Widget | add-product four steps, offline badge states | golden path |
| Integration | full offline → sync → upgrade cycle | 1 scripted test |
| Backend | FastAPI endpoint tests with test client | all `/api/v1/` routes |
| Rules | Firestore emulator: buyer cannot write product; artisan cannot read another's draft | 6 assertions minimum |
| Manual | airplane-mode script from §16 | before every demo |

**Non-negotiable test:** create a product in airplane mode, restore network, verify exactly one document exists and `priceFinal` is unchanged.

---

# 15 · BUILD & DEPLOYMENT

## 15.1 Environments

| Env | Firebase project | Backend | Purpose |
|---|---|---|---|
| `dev` | `pathashilpa-dev` | `localhost:8000` | daily work, seed data |
| `demo` | `pathashilpa-demo` | Render service | frozen, judged build |

## 15.2 Build commands

```bash
# Backend — local development
cd pathashilpo_backend
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000

# Backend — Docker
docker build -t pathashilpo-backend .
docker-compose up

# Backend — deploy to Render
# Configured via render.yaml, auto-deploys from git push

# Cloud Functions
cd pathashilpo_backend/functions
npm install
npm run build
firebase deploy --only functions

# Flutter app
flutter build apk --release \
  --dart-define=BACKEND_URL=https://pathashilpo-backend.onrender.com \
  --dart-define=ENV=demo

# Web
cd pathashilpa_web && npm run build && vercel --prod
```

## 15.3 Demo checklist

- [ ] Seed 3 artisans, 9 products
- [ ] Backend deployed on Render, health check passing
- [ ] Cloud Functions deployed, `onUserCreated` verified
- [ ] All env vars set on Render (Gemini, Sarvam, Bhashini, fal, Firebase SA)
- [ ] Signed release APK on two physical devices
- [ ] Airplane-mode path rehearsed end to end
- [ ] Backend Gemini/Sarvam/fal endpoints verified
- [ ] Web deployed, all links resolve
- [ ] Screen recording captured **before** the live demo, as insurance

---

# 16 · TECHNICAL RISKS

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| TR-1 | Gemini returns non-JSON | Medium | High | `responseMimeType`, fence stripping, key validation, template fallback |
| TR-2 | Device ASR unavailable / no Hindi pack | Medium | High | Tier 3 record-and-form always available |
| TR-3 | Rules `get()` blows read quota | Low | Medium | Small demo dataset; migrate to custom claims post-MVP |
| TR-4 | Storage upload stalls on 2G | High | Medium | Upload processed image first, original last; queue survives restart |
| TR-5 | Duplicate products on retry | Medium | High | `localId` as document id — structurally impossible |
| TR-6 | ~~Gemini key extracted from APK~~ | ~~Certain~~ | ~~N/A~~ | **Resolved:** all keys server-side on Render |
| TR-7 | Price differs after sync | Low | **Critical** | `priceFinal` never server-overwritten; assertion in integration test |
| TR-8 | Render cold start latency | Medium | Medium | Keep free-tier service warm with cron ping; fallback to Cloud Functions |
| TR-9 | fal.ai queue timeout | Medium | Low | 30 s timeout; degrade to crop/pad; background removal marked pending |
| TR-10 | Sarvam/Bhashini both unavailable | Low | Medium | Device ASR (Tier 2) + record-only (Tier 3) always available |

---

# 17 · APPENDIX

## 17.1 Environment variables — Backend (Render)

```
# AI Services
GEMINI_API_KEY              Google AI Studio
BHASHINI_API_KEY            ULCA
BHASHINI_USER_ID            ULCA
SARVAM_API_KEY              Sarvam AI
FAL_KEY                     fal.ai

# Firebase
FIREBASE_SERVICE_ACCOUNT    JSON service account key (base64 or raw)
FIREBASE_PROJECT_ID         Firebase project ID

# App
ENV                         dev | demo
PORT                        8000 (Render default: 10000)
CORS_ORIGINS                Flutter app origin, web origin
```

## 17.2 Environment variables — Flutter app

```
BACKEND_URL                 https://pathashilpo-backend.onrender.com
ENV                         dev | demo
```

## 17.3 Environment variables — Web

```
# .env
VITE_FIREBASE_API_KEY  VITE_FIREBASE_PROJECT_ID  VITE_FIREBASE_APP_ID …
```

## 17.4 Pricing constants

```dart
const fairWagePerHour = 150;   // ₹
const overheadFactor  = 1.15;
const marginFactor    = 1.25;
const maxFactor       = 1.30;
const roundTo         = 50;    // ₹
```

> 🟢 The **cost floor stays deterministic forever** — it is what makes the price explainable, identical offline, and a real floor under the artisan's earnings. 🔵 Only the market band above it becomes learned, once realised-sale data exists (§19.5). No ML ever computes the floor.

## 17.5 Firestore emulator

```bash
firebase emulators:start --only firestore,auth,storage
```
Rules tests live in `test/rules/` and run against the emulator in CI.

## 17.6 Open technical decisions

1. Custom claims via Cloud Function — `on_user_created` defined, needs implementation
2. On-device background removal (`u2netp` TFLite) — deferred; fal.ai handles it server-side
3. Perceptual hashing library for duplicate detection — interface defined, implementation pending
4. Whether to ship an APK download from the marketing site
5. Render free-tier vs paid — evaluate cold start impact during demo rehearsal
6. Sarvam vs Bhashini priority ordering — currently Sarvam primary, may swap based on testing
7. Whether the app palette (`PROJECT_CONTEXT.md` §6) and the marketing palette (`PRD.md` §13) should be unified — currently two unrelated colour systems

---

# 18 · IMPLEMENTATION STATUS

Live as of 2026-08-31. Authoritative detail in [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) §8.

## 18.1 Backend — built and verified

| Endpoint | Provider | Fallback | Status |
|---|---|---|---|
| `POST /api/v1/ai/listing` | Gemini 2.0 Flash | Python template fill → `generated_by: "template"` | ✅ |
| `POST /api/v1/ai/image` | fal.ai `birefnet` → `clarity-upscaler` | original image, `degraded: true` | ✅ |
| `POST /api/v1/ai/voice` | Sarvam AI → Bhashini ULCA | HTTP 502 → client falls to device ASR | ✅ |
| `GET /health` | — | — | ✅ |

Verified against a running server with no provider keys: 401 without a token, 200 `generated_by: template`, 200 `degraded: true`, clean 502.

Also built: `core/config.py` (pydantic-settings), `schemas/ai.py`, all four service clients, CORS, router aggregation.

## 18.2 Backend — not started

`POST /api/v1/sync` · `auth` / `products` / `enquiries` / `rfq` endpoints · `firebase_service.py` · `db/` · Cloud Functions · `sync/` TypeScript · `firestore.rules` / `storage.rules` / `firestore.indexes.json` · `Dockerfile` / `render.yaml`.

## 18.3 ⚠ Blocking risks

1. **Auth is a stub.** `app/core/security.py` accepts any non-empty bearer token and does **not** call `firebase_admin.auth.verify_id_token()`. Deliberate, to unblock local development — **must be replaced before any deploy**, or the server-side keys it guards are open to quota abuse.
2. **No rate limiting** on any AI endpoint, contrary to §6. Combined with (1), an exposed instance can burn the Gemini/fal/Sarvam quotas.
3. **No backend tests.** §14 requires TestClient coverage of all `/api/v1/` routes; verification so far has been manual.
4. `fal_service` catches bare `Exception` on both provider calls — intentional for graceful degradation, but it masks real bugs until logging is added.

## 18.4 Frontend — blocked

🔴 The Flutter SDK is not installed and **no `pubspec.yaml` exists**, so `pathashilpo_frontend/` is not yet a valid Flutter project. All ~60 Dart sources are 0 bytes and `assets/data/medians.json` is empty. Nothing can be compiled, analysed or run until the toolchain lands.

---

# 19 · POST-MVP ARCHITECTURE 🔵

Everything in this section is **designed but not built**. It exists so that MVP decisions stay forward-compatible — no MVP code should have to be discarded to reach any of it.

**Governing constraint:** every extension must preserve the four invariants in §9 — idempotency via `localId`, `priceFinal` never server-overwritten, the artisan is never blocked, and the ≈ 400 KB payload budget.

## 19.1 Speech — full Indic coverage

MVP ships `hi` with `bn` partial. Full product targets all 22 scheduled languages via Bhashini.

- `SpeechInput` already carries `languageCode`; no contract change is needed — this is a configuration and pipeline-cache expansion, not a redesign
- Extend `bhashini_service._pipeline_cache` to a per-language LRU with a TTL, backed by Redis once more than one backend instance runs (§19.10)
- Add dialect hinting: `sourceLanguage` plus an optional `dialect` field, since an artisan may speak Bundeli while the UI runs in Hindi
- **Language-pack negotiation:** the client sends its supported locales; the backend replies with which tier will serve them, so the UI can set expectations before recording

## 19.2 Image — on-device matting

MVP does background removal online only; offline drafts show the raw photo with a "will be cleaned on sync" note.

- Bundle **`u2netp` TFLite** (~5 MB) to give offline background removal, raising the offline listing to near-parity with online
- Requires re-checking the §12 APK budget — see §19.3
- The `ImageService` interface is unchanged; this is a new `ImageOffline` implementation behind the existing router (AD-5)
- `ImageResult.backgroundRemoved` becomes true offline, and the sync upgrade becomes a quality improvement rather than a first-time removal

## 19.3 On-device ML — model strategy

MVP bundles **no** ML models, which is what keeps the APK ≤ 40 MB (§12). The full product revisits this as a single deliberate budget decision rather than four separate ones.

| Model | Purpose | Approx. size | Replaces |
|---|---|---|---|
| `u2netp` TFLite | offline background removal | ~5 MB | centre-crop + white pad |
| **Vosk** (Hindi small) | offline Indic ASR | ~40 MB | device ASR (Tier 2) |
| **MobileNetV3** | on-device quality scoring | ~4 MB | Laplacian blur/brightness |
| **CLIP** (mobile variant) | offline zero-shot tagging | ~30 MB+ | transcript keyword spotting |

**Decision required before adopting any of these:** Vosk and CLIP alone exceed the entire current APK budget. Realistic paths are (a) raise the budget and accept a larger download over 2G, (b) ship **dynamic feature modules** so models download on Wi-Fi after install, or (c) adopt only `u2netp` and MobileNetV3, whose combined ~9 MB fits.

**Recommended: (b) dynamic delivery** — the base APK stays small for the low-end target device, and the artisan opts into offline AI when bandwidth allows.

## 19.4 Listing — image-conditioned generation

MVP sends **text only** to Gemini (§8.1) to hold latency and cost down.

- Full product sends the processed image alongside the transcript, letting the model ground colour, material and weave in what it can actually see
- Raises per-call cost and latency — gate it behind connection quality, and keep the text-only path as the fallback tier
- Output contract is unchanged, so `ListingResult` needs no migration; only `generatedBy` gains a `gemini_vision` value

## 19.5 Pricing — ML market band

**The cost floor never becomes ML.** It stays the deterministic formula in §17.4 — that is what makes the price explainable and identical offline, and it is the artisan's protection against loss-making sales. Only the *market band* becomes learned.

```
floor      = deterministic          ← unchanged, forever
suggested  = f(floor, learned market band)
max        = f(suggested, learned demand signal)
```

- Train on **realised sale prices**, not listing prices — the dataset only becomes real once orders flow (§19.9)
- Gradient-boosted trees (LightGBM) over craft type, cluster, material, hours, season and realised price. Rejected for MVP purely because no dataset exists (AD-6)
- Serve as a batch-computed median table refreshed nightly into `cache_medians`, **not** as a live inference call — this preserves offline parity and adds no latency
- **Invariant:** a recomputed band must never alter a confirmed `priceFinal` (§9.4)

## 19.6 Discovery — embeddings and vector search

MVP uses Firestore `array-contains-any` over `tags`, which cannot express similarity or handle vernacular queries.

- Generate an embedding per product at sync time (backend-side, during the AI upgrade step) and store it alongside the document
- Firestore's native vector search, or a dedicated index if scale demands it
- Enables "sarees like this one", multilingual query matching, and RFQ→artisan matching by semantic fit rather than exact craft string
- **RFQ matching** graduates from `craft + cluster + quantity` filtering to ranked semantic match

## 19.7 Moderation & provenance

MVP ships the data model (`flagged`, `flagReason`, `perceptualHash`) with a stub screen behind real rules.

- **Perceptual hashing** — compute on upload, compare server-side to detect the same photograph relisted by a different account. Interface is defined in the MVP schema; the implementation and the comparison index are the deferred part
- **Moderator review queue** — a real Firestore-backed work queue with claim/release semantics so two moderators never review the same item
- **Provenance verification** — `verifiedBy` moves from a free-text field to a reference to the verifying authority, with an audit trail

## 19.8 Identity — KYC, moderator and department tooling

- **KYC verification** — MVP accepts document *images* and verifies nothing, and **stores no Aadhaar number, ever** (§5.6). The full product integrates an authorised verification provider; the no-Aadhaar-storage rule survives that change unchanged
- **Moderator tooling** — takedown workflow, artisan verification, appeal handling. The Security Rules already grant exactly the right field-level permissions (§5.2), so this is UI work over an existing authorisation model
- **Department dashboards** — read-only cluster analytics: active artisans, listings per month, median realised price, orders fulfilled. `analytics/{doc}` and the `dept` role already exist in the rules with write denied to everyone

## 19.9 Commerce — channels, orders, payments

The largest deferred subsystem, and the one the MVP most deliberately avoids.

**Channel publishing.** MVP renders a mocked status chip. Full product implements real GeM and ONDC catalog publish plus order sync. `product.channels[]` already models this as a list, so no schema migration is needed — only the adapters behind it.

**Order lifecycle.** MVP has enquiries and RFQs but no orders. Full product adds an `orders/{orderId}` collection with a state machine (`placed → accepted → in_production → shipped → delivered → settled`), which is the prerequisite for realised-price data (§19.5).

**Payments and escrow.** Out of MVP entirely — the app says "Enquire", never "Buy". The full product requires escrow, because made-to-order craft means the artisan commits materials and weeks of labour before payment. **This is a regulatory and trust problem before it is an engineering one** and must not be bolted onto the MVP.

**Logistics.** Pickup from villages with unreliable addressing is a genuinely hard problem and is explicitly not solved here (`PRD.md` §5.4 — not a logistics company). Expect an aggregator integration.

## 19.10 Backend scaling

MVP runs a single Render service, and the Bhashini pipeline cache is an in-process dict — correct for one instance, wrong for several.

- Move the pipeline-config cache to **Redis** the moment a second instance exists, or each instance re-fetches and the §8.2 "do not re-fetch per call" rule silently breaks
- Extract sync and AI upgrade into a **background worker queue** so `POST /api/v1/sync` returns as soon as the document is durable, rather than holding the request through the AI calls
- Add **rate limiting** per uid — already required by §6 and still missing (§18.3)
- Render cold start (TR-8) stops being a workaround and becomes a paid always-on service

## 19.11 Financial services

- **Credit scoring** — sales history becomes an underwriting signal for working-capital loans. Requires the order data from §19.9 and is meaningless before it. Carries real fairness obligations: an opaque model deciding rural credit is exactly the kind of system that needs an audit trail and an appeal route
- **Export enablement** — HS code classification, IEC registration assistance, export documentation
- **Cluster co-operatives** — pooled fulfilment so a cluster can jointly service an order no single artisan could take. Needs a group entity in the data model, which does not exist today

## 19.12 Observability

MVP deliberately ships **no analytics SDK and no crash reporter** (§13.2) — a defensible privacy choice for this user base.

- Full product adds crash reporting and metrics with **explicit opt-in**, not silently
- Structured backend logging to stdout is already the Render contract; add request tracing across the client → FastAPI → provider chain so a failed listing can be followed end to end
- **The privacy posture in §5.6 constrains this permanently** — no location tracking, and voice audio stays deletable by the artisan

## 19.13 Sequencing

Dependencies, not a schedule:

```
MVP ships
   │
   ├─► real auth (§18.3)         ── blocks every deploy
   ├─► rate limiting (§19.10)    ── blocks public exposure
   │
   ├─► orders (§19.9) ──┬─► realised-price data ──► ML pricing (§19.5)
   │                    ├─► credit scoring (§19.11)
   │                    └─► payments & escrow (§19.9)
   │
   ├─► moderation queue (§19.7)  ── needed before open registration
   ├─► KYC verification (§19.8)  ── needed before money moves
   │
   └─► on-device models (§19.3)  ── independent; gated on the APK budget decision
```

**Two items block everything else and are already overdue: real Firebase token verification, and rate limiting.**

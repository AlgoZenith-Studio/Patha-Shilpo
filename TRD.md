# PATHASHILPA — TECHNICAL REQUIREMENTS DOCUMENT

**Version** 1.0 · MVP
**Companion to** `PATHASHILPA-PRD.md` (product), `PATHASHILPA-MVP-ARCHITECTURE.md` (structure), `CONTEXT.md` (agent brief)
**Audience** engineers building the system

---

# 1 · PURPOSE & SCOPE

This document specifies **how** the system is built: architecture, schemas, contracts, algorithms, security rules, budgets and test criteria. Product rationale lives in the PRD and is not repeated here.

**In scope:** Flutter client, Firebase backend, AI service layer, sync engine, React marketing site.
**Out of scope:** payment rails, GeM/ONDC production integration, ML model training.

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
       │                                │ read-only
       │ HTTPS                 ┌────────┴─────────┐
       ▼                       │   REACT WEB      │
┌──────────────────┐           │  (Vercel)        │
│  AI PROVIDERS    │           └──────────────────┘
│  Gemini API      │
│  Bhashini / ULCA │
└──────────────────┘
```

## 2.2 Containers

| Container | Runtime | Responsibility |
|---|---|---|
| `pathashilpa_app` | Flutter / Android | UI, on-device AI, offline store, sync engine, direct SDK + HTTPS calls |
| Firebase Auth | managed | identity, phone OTP, custom claims |
| Cloud Firestore | managed | system of record |
| Cloud Storage | managed | images, audio |
| Gemini API | external | listing generation |
| Bhashini / ULCA | external | ASR, MT, TTS |
| `pathashilpa_web` | Vite/React on Vercel | marketing site, read-only Firestore |

## 2.3 Architectural decisions

| # | Decision | Rationale | Rejected alternative |
|---|---|---|---|
| AD-1 | No custom backend server | Firebase SDK + Rules removes an entire tier; 2-day budget | FastAPI on Render — extra deploy surface, cold starts |
| AD-2 | AI calls made client-side | No server to proxy through | Cloud Functions — cold start + Blaze plan |
| AD-3 | One app, role switch | ~30% extra code vs 100% for a second app | Two Flutter apps |
| AD-4 | Hive over SQLite | Key-value fits draft objects; zero schema migration cost | Drift/SQLite |
| AD-5 | Router pattern for every AI service | Offline parity is the product thesis | Try/catch fallbacks scattered in UI |
| AD-6 | Deterministic pricing, no ML | Explainable, identical offline, zero training data | LightGBM — no dataset exists yet |

**AD-2 risk, stated openly:** the Gemini key ships in the APK via `--dart-define`. Acceptable for a hackathon build; production requires a proxy. Do not claim otherwise.

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

## 3.3 Target device baseline

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
5  Role mirrored into session box for shell selection
```

**Custom claims:** desirable but require a Cloud Function. **MVP decision:** rules read `users/{uid}.role` via `get()`. Costs one document read per rule evaluation; acceptable at demo scale. Document this trade-off.

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
| `GEMINI_API_KEY` | `--dart-define` at build | **in the APK — known limitation** |
| `BHASHINI_API_KEY` | `--dart-define` | same |

Mitigations for the demo: restrict the Gemini key to the Android package + SHA-1, set a quota cap, rotate after the event.

## 5.5 Privacy

- Voice audio uploaded only on sync; artisan can delete any product and its media
- No Aadhaar number is ever stored — documents are images only, unverified in MVP
- PII fields: `phone`, `name`, `village`, `photoUrl`. No location tracking, no analytics SDK
- Data deletion: delete `artisans/{uid}` + `users/{uid}` + all owned products and Storage paths

---

# 6 · SERVICE CONTRACTS (client-internal)

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
  int tier;                     // 1 bhashini | 2 device | 3 record-only
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

---

# 7 · EXTERNAL API CONTRACTS

## 7.1 Gemini — listing generation

```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent
     ?key={GEMINI_API_KEY}
Content-Type: application/json

{
  "contents":[{"parts":[{"text":"<prompt from CONTEXT.md §8>"}]}],
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
- Never send the image to Gemini in MVP — text only, keeps latency and cost down

## 7.2 Bhashini (ULCA) — ASR

```
1  POST /ulca/apis/v0/model/getModelsPipeline    → pipeline config + callback URL
     headers: userID, ulcaApiKey
2  POST {callbackUrl}                            → compute
     headers: {inferenceApiKey.name}: {value}
     body: audioContent (base64), sourceLanguage
```

Timeout **10 s** → fall to Tier 2. Cache the pipeline config for the session; do not re-fetch per call.

## 7.3 Failure matrix

| Service | Timeout | Retry | Fallback |
|---|---|---|---|
| Gemini | 12 s | 1 | template listing |
| Bhashini ASR | 10 s | 0 | device ASR |
| Bhashini TTS | 8 s | 0 | flutter_tts |
| Firestore write | SDK default | SDK offline persistence | Hive queue |
| Storage upload | 60 s | 3, backoff | stay queued |

---

# 8 · OFFLINE & SYNC ENGINE

## 8.1 Product state machine

```
CAPTURED
   │ local processing completes
   ▼
OFFLINE_PROCESSED   ← artisan can sell from here; listing is complete
   │ connectivity restored && queue reached this item
   ▼
SYNCING
   │ upload media → write doc → request AI upgrade
   ▼
AI_UPGRADED
   │ status set live
   ▼
LIVE
```

Any transition may fail → return to `OFFLINE_PROCESSED`, increment attempts, requeue. **No state is terminal-on-error.**

## 8.2 Idempotency

- `localId` = UUID v4 generated at capture, never regenerated
- Server document id **is** the `localId` → repeated writes upsert, never duplicate
- Storage paths keyed by `localId` → re-upload overwrites

## 8.3 Queue algorithm

```
loop while online && queue not empty:
    item = queue.peek()
    if now < item.nextAttemptAt: sleep; continue
    try:
        upload original.jpg   (if not uploaded)
        upload processed.jpg  (if exists)
        upload audio.m4a      (if exists)
        firestore.set(products/{localId}, payload, merge:true)
        if item needs AI upgrade:
            listing = gemini(...)      // best effort
            price   = pricing(...)     // recompute, must match local
            firestore.update(...)
        state = LIVE
        queue.pop()
    catch e:
        item.attempts += 1
        item.nextAttemptAt = now + min(2^attempts, 30) seconds
        if item.attempts > 8: mark item needs_attention, move to back
```

## 8.4 Conflict resolution

**Server wins**, with one exception: `priceFinal` is artisan-authored and is never overwritten by a server-side recomputation. If a recomputed `priceSuggested` differs from the local one, the local value is retained and the difference logged — the artisan must never see the price change after they confirmed it.

## 8.5 Payload budget

| Item | Target | Method |
|---|---|---|
| processed.jpg | ≤ 300 KB | 1200×1200, JPEG q75 |
| original.jpg | ≤ 1.5 MB | uploaded last, lowest priority |
| audio.m4a | ≤ 100 KB | 16 kHz mono, 30 s cap |
| Firestore doc | ≤ 8 KB | text only |
| **Per product** | **≈ 400 KB** | excluding original |

---

# 9 · INTERNATIONALISATION

- `flutter_localizations` + `gen_l10n`; ARB files `app_en.arb`, `app_hi.arb`, `app_bn.arb`
- Resolution: `session.locale` → device locale → `en`
- **All artisan-facing primary buttons render English + Hindi simultaneously**, independent of locale
- `intl` for currency (`₹#,##,###` Indian grouping) and dates
- Speech locale is independent of UI locale — an artisan may run the UI in Hindi and speak Bundeli
- ARB keys namespaced: `artisan_*`, `buyer_*`, `common_*`, `error_*`

---

# 10 · CLIENT ARCHITECTURE

## 10.1 Layers

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

## 10.2 State management

`provider` only. Three app-scoped providers:

| Provider | Holds |
|---|---|
| `AuthProvider` | uid, role, auth state stream |
| `ConnectivityProvider` | online bool, sync status |
| `LocaleProvider` | active locale |

Screen state stays local (`setState`) — no global store for the MVP.

## 10.3 Routing & RBAC guard

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

## 10.4 Add-product screen state

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

---

# 11 · PERFORMANCE BUDGETS

Measured on the §3.3 baseline device.

| Operation | Budget |
|---|---|
| Cold start → first frame | ≤ 3.0 s |
| Camera open | ≤ 1.0 s |
| Image quality check | ≤ 300 ms |
| Crop + pad + compress | ≤ 1.5 s |
| Device ASR (10 s speech) | ≤ 2.0 s after stop |
| Gemini listing round-trip | ≤ 6.0 s (12 s timeout) |
| Price computation | ≤ 10 ms (pure arithmetic) |
| **Offline draft: photo → review screen** | **≤ 8 s total** |
| Sync one product on 3G | ≤ 25 s |
| Buyer grid, 20 items, cached | ≤ 1.5 s |

**APK size target:** ≤ 40 MB (no bundled ML models in MVP).

---

# 12 · ERROR HANDLING & OBSERVABILITY

## 12.1 Error taxonomy

| Class | Example | User-visible behaviour |
|---|---|---|
| Recoverable-silent | Gemini timeout | template listing used; no message |
| Recoverable-informed | upload failed | "Will retry when connected" + retry button |
| User-actionable | photo too blurry | "Photo is blurry — take it again" + retake |
| Blocking | invalid OTP | inline field error |
| Fatal | Firebase init failure | error screen with restart |

**Rule:** the artisan never sees a technical error string. Every message is a plain sentence in their locale with one action.

## 12.2 Logging

`AppLogger` wrapper with levels. In debug, log to console; in release, log to a Hive ring buffer of the last 200 events, exportable from a hidden settings tap. **No analytics SDK, no crash reporter in MVP** — a deliberate privacy choice, defensible in Q&A.

---

# 13 · TESTING

| Layer | Coverage target | What |
|---|---|---|
| Unit | pricing, template listing, queue backoff, idempotency | ≥ 80% on `ai/` + `sync/` |
| Widget | add-product four steps, offline badge states | golden path |
| Integration | full offline → sync → upgrade cycle | 1 scripted test |
| Rules | Firestore emulator: buyer cannot write product; artisan cannot read another's draft | 6 assertions minimum |
| Manual | airplane-mode script from §14 | before every demo |

**Non-negotiable test:** create a product in airplane mode, restore network, verify exactly one document exists and `priceFinal` is unchanged.

---

# 14 · BUILD & DEPLOYMENT

## 14.1 Environments

| Env | Firebase project | Purpose |
|---|---|---|
| `dev` | `pathashilpa-dev` | daily work, seed data |
| `demo` | `pathashilpa-demo` | frozen, judged build |

## 14.2 Build commands

```bash
flutter build apk --release \
  --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY \
  --dart-define=BHASHINI_API_KEY=$BHASHINI_API_KEY \
  --dart-define=ENV=demo

cd pathashilpa_web && npm run build && vercel --prod
```

## 14.3 Demo checklist

- [ ] Seed 3 artisans, 9 products
- [ ] Signed release APK on two physical devices
- [ ] Airplane-mode path rehearsed end to end
- [ ] Gemini quota verified; key restricted to package + SHA-1
- [ ] Web deployed, all links resolve
- [ ] Screen recording captured **before** the live demo, as insurance

---

# 15 · TECHNICAL RISKS

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| TR-1 | Gemini returns non-JSON | Medium | High | `responseMimeType`, fence stripping, key validation, template fallback |
| TR-2 | Device ASR unavailable / no Hindi pack | Medium | High | Tier 3 record-and-form always available |
| TR-3 | Rules `get()` blows read quota | Low | Medium | Small demo dataset; migrate to custom claims post-MVP |
| TR-4 | Storage upload stalls on 2G | High | Medium | Upload processed image first, original last; queue survives restart |
| TR-5 | Duplicate products on retry | Medium | High | `localId` as document id — structurally impossible |
| TR-6 | Gemini key extracted from APK | Certain | Low (demo) | Restricted key, quota cap, rotate after event |
| TR-7 | Price differs after sync | Low | **Critical to the pitch** | `priceFinal` never server-overwritten; assertion in integration test |

---

# 16 · APPENDIX

## 16.1 Environment variables

```
GEMINI_API_KEY          Google AI Studio
BHASHINI_API_KEY        ULCA
BHASHINI_USER_ID        ULCA
ENV                     dev | demo

# web/.env
VITE_FIREBASE_API_KEY  VITE_FIREBASE_PROJECT_ID  VITE_FIREBASE_APP_ID …
```

## 16.2 Pricing constants

```dart
const fairWagePerHour = 150;   // ₹
const overheadFactor  = 1.15;
const marginFactor    = 1.25;
const maxFactor       = 1.30;
const roundTo         = 50;    // ₹
```

## 16.3 Firestore emulator

```bash
firebase emulators:start --only firestore,auth,storage
```
Rules tests live in `test/rules/` and run against the emulator in CI.

## 16.4 Open technical decisions

1. Custom claims via Cloud Function — post-MVP or during, if Blaze is enabled
2. On-device background removal (`u2netp` TFLite) — deferred; decide after the demo
3. Perceptual hashing library for duplicate detection — interface defined, implementation pending
4. Whether to ship an APK download from the marketing site
# Final Project Context: Patha-Shilpa (v1.0 MVP)

> **Status**: OMNIPRESENT — Initialized for all MAS Agents (@PM, @GUARD, @ARCH, @DESIGN, @FE, @BE, @SEC, @ETHICS, @QA, @OPS, @DATA, @DEBUGGER, @REPAIR)
> **Version**: 1.0
> **Source of Truth**: Patha-Shilpa TRD v1.0, MVP Architecture Spec, and Defined AI Matrix
> **Theme Palette (Strict 5 HEX Codes)**: `#fffbb6` (255,251,182), `#d4a262` (212,162,98), `#cc915c` (204,145,92), `#bb8f67` (187,143,103), `#513a24` (81,58,36)

---

## 1. Product Vision & Mission
**Patha-Shilpa** is an offline-first, voice-guided digital cataloging, pricing, and discovery platform for rural Indian artisans. It solves the critical digital inclusion barrier by allowing artisans to photograph handicrafts, speak product descriptions in vernacular Hindi/dialects, receive explainable fair-wage pricing, and generate complete listings in airplane mode, seamlessly syncing and enhancing data once online.

---

## 2. Core Approved Tech Stack & AI Matrix

| Layer / Domain | Technology | Infrastructure / Host | Notes |
| :--- | :--- | :--- | :--- |
| **Mobile App** | **Flutter 3.5+ (Dart)** | Android (Baseline: Android 8.0, 2GB RAM) | Single binary serving dual shells (`artisan` & `buyer`) |
| **Backend & Storage** | **Firebase Auth, Firestore, Cloud Storage** | Google Cloud Platform | Managed BaaS with authoritative Firestore Security Rules |
| **Offline DB & Queue** | **Hive & Hive Flutter** | On-Device Key-Value Store | Boxes: `session`, `drafts`, `queue`, `cache_products`, `cache_medians`, `media` |
| **Visual AI (Cloud)** | **RMBG-1.4, Real-ESRGAN, CLIP** | fal.ai / Cloud Inference | RMBG-1.4 for background removal, Real-ESRGAN upscaling, CLIP zero-shot tagging |
| **Visual AI (Device)** | **MobileNetV3** | On-Device Inference / Processing | Laplacian blur/brightness check, MobileNetV3 quality assessment, 1200x1200 crop/pad |
| **Voice AI (Cloud)** | **Sarvam AI & Bhashini (ULCA)** | Cloud Indic APIs | High-accuracy Indic ASR, vernacular translation, Indic TTS |
| **Voice AI (Device)** | **Vosk** | On-Device ASR Engine | Zero-latency offline Hindi/Indic speech-to-text; Tier 3 record + guided form fallback |
| **Generative Copy** | **Gemini 2.0 Flash** | Google AI Studio | Structured bilingual JSON (`title`, `description`, `tags`, `colors`, `craftType`) |
| **Listing Fallback** | **Rule-based ARB Template Fill** | On-Device Engine | Keyword spotter + ARB template interpolation |
| **Pricing Engine** | **Deterministic Fair-Wage Formula** | On-Device & Cloud Parity | `floor = (materialCost + hours * 150) * 1.15`, `suggested = round(floor * 1.25, 50)` |
| **Web Client** | **React 18 + TypeScript + Vite + Tailwind** | Vercel / Cloudflare Pages | Marketing, artisan stories, read-only Firestore public showcase |
| **Localization** | **Flutter i18n (`intl`, `gen_l10n`)** | ARB files (`app_en.arb`, `app_hi.arb`, `app_bn.arb`) | Dual-language simultaneous labels on primary artisan buttons |

---

## 3. Four-Tier Role-Based Access Control (RBAC)

1. **`artisan`**: Chosen at first login; full CRUD on own profile and products; view and respond to buyer enquiries on own products.
2. **`buyer`**: Chosen at first login; read all live products, send enquiries and RFQs, manage buyer profile and favorites.
3. **`moderator`**: Flag/unflag products, verify artisan credentials, enforce takedowns.
4. **`dept`**: Read-only cluster analytics dashboards (active artisans, monthly listings, median prices).

**Enforcement Authority**: Firestore Security Rules validate every operation against `users/{uid}.role`. Custom claim or `get()` lookup ensures tamper-proof authorization.

---

## 4. Offline Sync & Idempotency Rules

- **Client UUID (`localId`)**: Generated upon draft creation, used as the Firestore document ID and Cloud Storage path. Prevents duplicates across retry cycles.
- **State Machine**: `CAPTURED` $\rightarrow$ `OFFLINE_PROCESSED` $\rightarrow$ `SYNCING` $\rightarrow$ `AI_UPGRADED` $\rightarrow$ `LIVE`.
- **Conflict & Price Protection Invariant**: Server wins for copy/image enhancements; however, artisan-confirmed `priceFinal` is **never** overwritten by server recomputations.
- **Queue Algorithm**: FIFO with exponential backoff (2s $\rightarrow$ 4s $\rightarrow$ 8s $\rightarrow$ 30s cap) triggered via `connectivity_plus` stream and manual sync.

---

## 5. Architectural Contracts & Safety Gates

1. **Router Contract**: Every AI service (`ImageService`, `SpeechService`, `ListingService`, `PricingService`, `TtsService`) implements an abstract interface with online and offline implementations. Routers never throw unhandled exceptions to UI.
2. **Performance Budgets (Android 8.0 / 2GB RAM)**:
   - Cold start $\le$ 3.0s
   - Image quality check $\le$ 300ms
   - Offline draft creation (photo $\rightarrow$ review) $\le$ 8.0s total
   - Single product sync on 3G $\le$ 25s
   - Release APK size target $\le$ 40 MB
3. **No Technical Error Jargon**: Artisans only see plain, actionable vernacular sentences with single clear actions.

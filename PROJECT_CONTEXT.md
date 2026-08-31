# PROJECT CONTEXT — Pathashilpa

> **Status**: OMNIPRESENT — the single source of truth for every build agent and contributor
> **Version**: 2.0 (supersedes `final_project_context.md`, `temporary_project_context.md`, `pathashilpo.md`, `mvp.md`)
> **Last reconciled**: 2026-08-31
> **Companions**: [`PRD.md`](PRD.md) (what & why) · [`TRD.md`](TRD.md) (how)

**Precedence rule:** where documents disagree, **shipped code wins, then `TRD.md`, then this file, then `PRD.md`.** Anything not reconciled is listed in §10.

---

## 1 · VISION

Pathashilpa is an offline-first, voice-guided cataloguing, pricing and discovery platform for rural Indian artisans. An artisan photographs a handicraft, speaks a description in vernacular Hindi, receives an explainable fair-wage price, and gets a complete bilingual listing — **entirely in airplane mode** — which syncs and silently upgrades once online.

**Tagline:** Your craft. Your price. Your name.

---

## 2 · APPROVED TECH STACK

| Layer | Technology | Host | Notes |
| :--- | :--- | :--- | :--- |
| Mobile app | **Flutter 3.5+ (Dart)** | Android 8.0 baseline, 2 GB RAM | One binary, dual shells (`seller` + `buyer`) |
| Backend API | **FastAPI (Python 3.11)** | Docker on Render | AI orchestration, sync, API-key custody |
| Database & identity | **Firebase Admin SDK** | GCP / Firebase | Phone OTP, Firestore system of record |
| Media storage | **Firebase Cloud Storage** | GCP | Images and audio |
| Offline store | **Hive + hive_flutter** | on-device | `session`, `drafts`, `queue`, `cache_products`, `cache_medians`, `media` |
| Event triggers | **Cloud Functions (TypeScript)** | Firebase | `onUserCreated` custom claims; AI proxy fallbacks |
| Localization | **Flutter `intl` + `gen_l10n`** | ARB files | `app_en.arb`, `app_hi.arb`, `app_bn.arb` |

---

## 3 · AI MATRIX — every pipeline has an offline twin

**Design rule:** each pipeline is an abstract interface with an online and an offline implementation, plus a router that picks by connectivity. `XRouter.run()` **never throws to the UI.**

| Pipeline | Online | Offline |
| :--- | :--- | :--- |
| **Image** | fal.ai `birefnet` (background removal) → `clarity-upscaler` (enhancement) | Laplacian blur/brightness check + centre-crop and 1200×1200 white pad |
| **Speech** | Sarvam AI (primary) → Bhashini ULCA (fallback) | Tier 2 Android `speech_to_text`; Tier 3 record + guided attribute form |
| **Listing** | Gemini 2.0 Flash → structured bilingual JSON | Rule-based keyword spotting + ARB template fill |
| **Pricing** | Same deterministic formula + live Firestore medians | **Same deterministic formula** + cached medians JSON |
| **TTS** | Sarvam / Bhashini TTS | `flutter_tts` device Hindi voice |
| **Discovery** | Firestore `array-contains-any` on tags | *Not applicable — buyers are assumed online* |

### Client-side AI call chain
```
TIER 1  FastAPI backend    online · full AI pipeline · POST /api/v1/ai/*
   │    fails or timeout ↓
TIER 2  Cloud Function     online · callable fallback
   │    fails or offline ↓
TIER 3  ON-DEVICE          offline · deterministic fallback
```

### ⚠ Explicitly OUT of MVP
**Vosk, MobileNetV3 and CLIP** appeared in earlier drafts and are **not** in the MVP. Each requires bundling a model file, breaking the ≤ 40 MB APK budget and the "no bundled ML models" rule (`TRD.md` §12). Their offline guarantees are met by the classical techniques above.

They are **not abandoned** — the full-product design for all of them, including the APK-budget decision that gates them, is specified in `TRD.md` §19.3. See also `PRD.md` §5.5.

### Full product vs MVP
`TRD.md` now carries **both tiers**: the complete target architecture and the MVP subset being built now, marked throughout with 🟢 MVP / 🟡 MVP-partial / 🔵 Post-MVP. The scope matrix is `TRD.md` §1.2; the deferred architecture is §19.

---

## 4 · PRICING — the one identical pipeline

```
floor     = (materialCost + hours × 150) × 1.15
suggested = round(floor × 1.25, 50)
max       = round(suggested × 1.30, 50)
```
Constants: `fairWagePerHour ₹150` · `overheadFactor 1.15` · `marginFactor 1.25` · `maxFactor 1.30` · `roundTo ₹50`

**This is the only pipeline that is bit-identical offline and online.** The price an artisan sees never changes after sync — say this in the demo.

---

## 5 · RBAC — one app, four roles

| Role | Set how | Can do |
| :--- | :--- | :--- |
| `artisan` | chosen at first login | own profile & products CRUD; respond to enquiries on own products |
| `buyer` | chosen at first login | read live products; create enquiries/RFQs; own buyer profile |
| `moderator` | set manually in console | flag/unflag products, verify artisans, take down listings |
| `dept` | set manually in console | read-only cluster analytics; no write anywhere |

Only `artisan` and `buyer` are reachable from the UI in MVP. `moderator` and `dept` exist in the model and rules so the architecture is complete and demonstrable.

**The role lives in three places, deliberately redundant:** Auth custom claim (what Rules read) · `users/{uid}.role` (client UI decisions) · Hive `session.role` (shell selection before the network responds — **never trusted for authorisation**).

**Enforcement:** route guards and widget guards are *cosmetic*. **Firestore & Storage Security Rules are the sole authority.**

---

## 6 · DESIGN SYSTEM — Flutter application

> This is the **only** design system in the project. The marketing website is out of repository scope (`PRD.md` §5.6), so the earlier palette conflict no longer exists.

### Palette — strict 5 HEX, no additions
| HEX | Role |
| :--- | :--- |
| `#fffbb6` | Scaffold background canvas |
| `#d4a262` | Heritage badges, verified GI tag highlights |
| `#cc915c` | Primary CTAs, FABs, active filter chips |
| `#bb8f67` | Card borders, dividers, unselected chip borders |
| `#513a24` | **All** typography, headings, high-contrast labels |

Plus `#FFFFFF` for card surfaces. Cards: 18dp radius, 0.8dp `#bb8f67` border. Bottom sheets: 24dp top corners.

### Typography
| Role | Family | Weights |
| :--- | :--- | :--- |
| Headings, AppBar | **Lora** | Bold w700, SemiBold w600 |
| Body, button labels, fields | **Kalam** | Regular w400, Bold w700 |
| Artisan stories, pull-quotes | **Rowan** | Medium, MediumItalic, SemiboldItalic |

### ⚠ MANDATORY Devanagari fallback
All three families are **Latin-only** — verified by parsing each OTF `cmap`: 58 Latin glyphs, **zero** codepoints in U+0900–U+097F (Devanagari) or U+0980–U+09FF (Bengali). Without mitigation every Hindi string renders as tofu boxes.

```dart
fontFamilyFallback: const ['Noto Sans Devanagari', 'Noto Sans Bengali', 'sans-serif'],
```
Required on **every** `TextStyle`. Costs 0 MB (Android 8+ ships Noto). **Must be visually confirmed on a real device before the demo.**

### Bilingual rule
**Every artisan-facing primary button renders English and Hindi simultaneously**, regardless of locale — white English label over `#fffbb6` Hindi subtext on `#cc915c`. This is a design rule, not a translation gap.

---

## 7 · OFFLINE ENGINE & SYNC INVARIANTS

### State machine
```
CAPTURED → OFFLINE_PROCESSED → SYNCING → AI_UPGRADED → LIVE
              ↑ artisan can sell from here
```
Any transition may fail → return to `OFFLINE_PROCESSED`, increment attempts, requeue. **No state is terminal-on-error.**

### The four invariants
1. **Idempotency** — `localId` (UUID v4) is generated at capture, never regenerated, and *is* the Firestore document id. Retries upsert; duplicates are structurally impossible.
2. **Price protection** — server wins on copy and image enhancements, but artisan-confirmed **`priceFinal` is never overwritten** by a server recomputation.
3. **Never blocked** — Tier 3 always produces a usable draft. The artisan never sees a blocking spinner or an error they must resolve.
4. **Payload budget** — `processed.jpg` ≤ 300 KB · `audio.m4a` ≤ 100 KB · `original.jpg` ≤ 1.5 MB (uploaded last) · ≈ 400 KB per product excluding original.

Queue: FIFO, one item at a time, exponential backoff `2^attempts` capped at 30 s, `needs_attention` after 8 attempts.

---

## 8 · IMPLEMENTATION STATUS

### Backend — `pathashilpo_backend/`
| Component | Status |
| :--- | :--- |
| `POST /api/v1/ai/listing` — Gemini + template fallback | ✅ built & verified |
| `POST /api/v1/ai/image` — fal.ai + degrade to original | ✅ built & verified |
| `POST /api/v1/ai/voice` — Sarvam → Bhashini → 502 | ✅ built & verified |
| `GET /health` | ✅ built & verified |
| `core/config.py`, `schemas/ai.py`, 4 service clients | ✅ built |
| `core/security.py` | ⚠ **STUB** — accepts any bearer token; does *not* verify with Firebase |
| `POST /api/v1/sync` | ❌ not started |
| `auth` / `products` / `enquiries` / `rfq` endpoints | ❌ empty placeholders |
| `firebase_service.py`, `db/` | ❌ not started |
| Cloud Functions, `sync/` TS, `firestore.rules`, Docker/Render config | ❌ not started |

### Frontend — `pathashilpo_frontend/`
Flutter 3.47.2 · 157 deps resolved · `flutter analyze` clean · Android release APK target configured.

| Component | Status |
| :--- | :--- |
| `pubspec.yaml`, `l10n.yaml`, fonts + assets registered | ✅ |
| `core/theme/` — palette, shape tokens, full `ThemeData` | ✅ |
| ARB i18n `en`/`hi`/`bn` + `LocaleProvider` | ✅ (`bn` partial by design) |
| 9 shared core widgets + routing + `app.dart`/`main.dart` | ✅ |
| `core/rbac/` — `RoleGuard` & auth claims model | ✅ |
| `features/auth/` — Splash, Phone Login, OTP Verify, Role Select | ✅ |
| `features/seller/` — Shell, Home, Products, Profile, Enquiries | ✅ |
| `features/seller/add_product/` — 4-step wizard (Photo, Voice, Costs, Pricing Review) | ✅ |
| `ai/pricing/` — deterministic FairWage pricing service & models | ✅ |
| `scripts/` — wireless ADB pair & connect scripts (`.ps1`, `.sh`) + `.env.example` | ✅ |
| `data/`, `ai/` cloud routers, `sync/` background engine | 🟡 in progress |
| `assets/data/medians.json` | ❌ empty, needs seeding |

---

## 9 · BUILD ORDER & DEMO

### Build order
**Foundation first (nothing else starts until these are agreed):** models · Hive init · Firestore refs · theme · ARB files · role enum + guard.

**Then in parallel:** (A) `ai/` routers + `sync/` engine → `add_product/` four steps · (B) auth + role select + artisan home/profile/products · (C) seed data + demo rehearsal. Buyer explore/product/profile/enquiries is a separate contributor's track.

**Last:** moderator/dept stubs — 30 minutes, large credibility payoff, they prove RBAC is architectural rather than cosmetic.

### What is real vs stubbed in MVP
| Capability | Status |
| :--- | :--- |
| Phone OTP auth · role selection · route guards · Security Rules | ✅ real |
| i18n EN + HI | ✅ real |
| Speech Tier 2 (device) and Tier 3 (record + form) | ✅ real |
| Image quality check + crop/pad | ✅ real |
| Gemini listing generation + offline template | ✅ real |
| Pricing (both tiers) | ✅ real |
| **Offline draft + sync engine** | ✅ real — **this is the demo** |
| Buyer browse + enquiry | ✅ real |
| Speech Tier 1 (Sarvam/Bhashini) | 🟡 if API keys arrive in time |
| Background removal / enhancement | 🟡 online only |
| RFQ | 🟡 form saves, no matching |
| Moderator / dept screens | ⬜ stub screens, real rules |
| GeM / ONDC publish | ⬜ mocked status chip, labelled |
| Payments | ⬜ out of scope |

### The demo script this architecture enables
1. Open app → choose "I make things"
2. **Turn on airplane mode**
3. Photograph the saree → speak in Hindi → enter cost and hours
4. Listing appears with title, description and price — **"Offline Draft"** badge visible
5. Network back on → badge changes to syncing → photo sharpens, copy improves, **price unchanged**
6. Switch to buyer mode → find the product → read the maker's story → send an enquiry
7. Back to artisan → enquiry has arrived, read aloud in Hindi

**Step 2 is the moment that wins it. Rehearse it until it is boring.**

---

## 10 · RUNNING & TESTING ON A PHYSICAL PHONE / EMULATOR

This section contains everything needed to pull the code, install dependencies, build the APK, and run it on an Android phone using either **Wireless ADB** or **USB Debugging**.

### 10.1 · Prerequisites & Setup (First-time / After `git pull`)

1. **Prerequisites on Developer Machine:**
   - **Flutter SDK** (3.24+ / 3.47+ recommended): `flutter --version`
   - **Android SDK Platform-Tools** (`adb`): included with Android Studio or standalone cmdline-tools
   - **Java / OpenJDK 17** (for Gradle builds)
2. **Install frontend dependencies:**
   ```bash
   cd pathashilpo_frontend
   flutter pub get
   ```
3. **Build the Release or Debug APK:**
   ```bash
   flutter build apk --release
   # APK location: pathashilpo_frontend/build/app/outputs/flutter-apk/app-release.apk
   ```

---

### 10.2 · Option A: Wireless Debugging (No USB Cable Needed)

Every phone session generates fresh ports and pairing codes. Device configuration is kept in `.env` (git-ignored) so developer-specific network details are never committed.

#### Phone Setup:
1. Ensure the phone and PC are connected to the **same Wi-Fi network**.
2. On your phone: **Settings → Developer Options → Wireless debugging → Turn ON**.
3. Tap **"Pair device with pairing code"**.
   - Note the **Pairing IP:Port** (e.g. `192.168.1.3:46127`) and the **6-digit Wi-Fi pairing code** (e.g. `301014`).
4. Look at the main **Wireless debugging** screen under *"IP address & Port"* for the **Connect IP:Port** (e.g. `192.168.1.3:41011`). *(Note: The connect port is different from the pairing port!)*

#### Environment Configuration:
1. In `pathashilpo_frontend/`, copy the example file:
   ```bash
   cp .env.example .env
   ```
2. Update `.env` with your current session values:
   ```env
   # From the "Pair device with pairing code" dialog
   ADB_PAIR_HOST=192.168.1.3
   ADB_PAIR_PORT=46127
   ADB_PAIR_CODE=301014

   # From the main Wireless debugging screen
   ADB_CONNECT_HOST=192.168.1.3
   ADB_CONNECT_PORT=41011

   # Optional: Path to platform-tools/adb if not automatically on PATH
   ANDROID_SDK_ROOT=

   APP_ID=com.example.pathashilpa
   ```

#### Run the Automation Script:
- **Windows (PowerShell):**
  ```powershell
  # Pair, connect, install APK, and launch:
  .\scripts\wireless_connect.ps1 -InstallApk

  # Or pair & connect only:
  .\scripts\wireless_connect.ps1
  ```
- **macOS / Linux / WSL (Bash):**
  ```bash
  chmod +x ./scripts/wireless_connect.sh
  
  # Pair, connect, install APK, and launch:
  ./scripts/wireless_connect.sh --install

  # Or pair & connect only:
  ./scripts/wireless_connect.sh
  ```

---

### 10.3 · Option B: USB Debugging (Zero-Config / Plug & Play)

If you prefer using a USB cable:

1. **Phone Setup:**
   - **Settings → Developer Options → USB Debugging → Turn ON**.
   - Connect phone to PC via USB cable.
   - Unlock phone and tap **"Allow USB Debugging"** (check *"Always allow from this computer"*).
2. **Verify ADB Connection:**
   ```bash
   adb devices -l
   # You should see your device listed as 'device' (not 'unauthorized')
   ```
3. **Install & Launch the APK:**
   ```bash
   # Direct install via adb:
   adb install -r build/app/outputs/flutter-apk/app-release.apk

   # Launch app on device:
   adb shell monkey -p com.example.pathashilpa -c android.intent.category.LAUNCHER 1
   ```
4. **Or run with live Flutter hot-reload:**
   ```bash
   flutter run -d <device_id>
   ```

---

### 10.4 · Option C: Direct Sideloading (Transferring APK to Friend)

If a team member just wants to test the app without developer tooling:
1. Send `pathashilpo_frontend/build/app/outputs/flutter-apk/app-release.apk` to their phone (via Drive, WhatsApp, or USB file transfer).
2. On Android phone: open Files app → tap `app-release.apk` → allow "Install unknown apps" from that source → tap **Install**.
3. Open **Pathashilpa** from the home screen.

---

## 11 · OPEN CONFLICTS & DECISIONS NEEDED

| # | Issue | Current resolution |
| :--- | :--- | :--- |
| 1 | ~~Two divergent design systems~~ | **Resolved** — the marketing site left repository scope, so only the app palette remains. |
| 2 | Product name — "Pathashilpa" / "Patha-Shilpa" / "Patha-Shilpo"; dirs are `pathashilpo_*` | Prose standardises on **Pathashilpa**; directory names left untouched |
| 3 | `AI_COWORKER/.../ARCHITECTURE.md` lists endpoints as `/ai/image/process` etc. | **Superseded** — shipped code and `TRD.md` §6.1 use `/ai/image`, `/ai/voice`, `/ai/listing` |
| 4 | Backend auth is a stub | Must be replaced with `verify_id_token()` before any deploy |
| 5 | `@GUARD` risk gate never ran | `AI_COWORKER/shared_memory/logs/risk_report.md` still `PENDING` |
| 6 | Devanagari rendering unproven | Must be confirmed on a physical Android handset |
| 7 | Frontend dir structure differs from earlier docs (`features/seller/` not `features/artisan/`, `core/widgets/` not `lib/widgets/`, `ai/voice/` not `ai/speech/`) | **On-disk structure is authoritative** |


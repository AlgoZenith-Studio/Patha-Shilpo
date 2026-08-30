# System Architecture Document: Patha-Shilpa (v1.0 MVP)

> **Owner**: `@ARCH` (System Architect)
> **Status**: APPROVED
> **Backend Stack**: Firebase (Auth, Firestore, Cloud Storage) + Serverless AI Proxies
> **Local Persistence**: Hive on-device boxes (`session`, `drafts`, `queue`, `cache_products`, `cache_medians`, `media`)
> **Frontend**: Flutter (Android Baseline: Android 8.0, 2GB RAM)

---

## 1. System Topology & Dual-Shell Design

```
┌──────────────────────────────────────────────────────────────┐
│  pathashilpo_frontend   FLUTTER · Single Binary, Dual Shells │
│  ├── 1. SELLER Mode     Onboarding, Add-Product, Enquiries   │
│  └── 2. BUYER Mode      Explore, Product PDP, Enquiries, RFQ │
└──────────────────────────────────────────────────────────────┘
                    │  Firebase SDK (Offline-Persistent) + HTTPS
                    ▼
┌──────────────────────────────────────────────────────────────┐
│  FIREBASE BACKEND                                            │
│  Auth (Phone OTP) · Firestore · Cloud Storage                │
│  Modular RBAC Rules (artisan, buyer, moderator, dept)        │
└──────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────────────────────┐
│  AI LAYER & SERVICE MATRIX                                   │
│  • Visual: MobileNetV3 (Device) <-> fal.ai RMBG-1.4/Real-ESRGAN/CLIP (Cloud)
│  • Voice:  Vosk (Device) <-> Sarvam AI + Bhashini ULCA (Cloud)
│  • Copy:   ARB Template (Device) <-> Gemini 2.0 Flash (Cloud)
│  • Price:  Deterministic Fair-Wage Formula (Identical Offline & Online)
└──────────────────────────────────────────────────────────────┘
```

---

## 2. Core Collections & Schema Summary

- **`users/{uid}`**: `uid`, `role` (`artisan` | `buyer` | `moderator` | `dept` — immutable), `phone`, `locale`, `createdAt`.
- **`artisans/{uid}`**: `name`, `nameHi`, `village`, `district`, `state`, `craft`, `cluster`, `giTag`, `story`, `storyHi`, `yearsOfPractice`, `photoUrl`, `verified`.
- **`buyers/{uid}`**: `name`, `phone`, `email`, `buyerType`, `company`, `gstin`, `interests[]`, `states[]`, `savedProducts[]`.
- **`products/{productId}`**: `productId` (== `localId`), `localId` (UUID v4), `artisanId`, `imageUrl`, `originalImageUrl`, `title`, `titleHi`, `description`, `descriptionHi`, `tags[]`, `material`, `craftType`, `colors[]`, `hoursOfWork`, `materialCost`, `priceFloor`, `priceSuggested`, `priceMax`, `priceFinal`, `priceReasoning`, `priceReasoningHi`, `state`, `status`, `speechTier`, `generatedBy`.
- **`enquiries/{enquiryId}`**: `productId`, `artisanId`, `buyerUid`, `buyerName`, `buyerPhone`, `buyerType`, `quantity`, `message`, `status` (`new` | `accepted` | `declined`).
- **`rfqs/{rfqId}`**: `buyerUid`, `craft`, `cluster`, `quantity`, `deadline`, `budgetMin`, `budgetMax`, `status`.

---

## 3. Idempotent Offline Sync & Conflict Resolution

- Every product draft generates an immutable UUID (`localId`) on device.
- Firestore upserts using `localId` as the document ID; duplicate uploads are structurally impossible.
- **Price Protection Invariant**: The artisan-confirmed `priceFinal` is never modified by server-side recomputations.

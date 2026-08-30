# PATHASHILPA — MVP ARCHITECTURE
### Minimum Offline-Viable Product · complete structure, no code

---

# 0 · SYSTEM SHAPE

```
┌──────────────────────────────────────────────────────────────┐
│  pathashilpa_app        FLUTTER · one binary, two roles      │
│  ├── ARTISAN mode       list, price, sell                    │
│  └── BUYER mode         browse, enquire, RFQ                 │
└──────────────────────────────────────────────────────────────┘
                    │  Firebase SDK + HTTPS
                    ▼
┌──────────────────────────────────────────────────────────────┐
│  FIREBASE                                                    │
│  Auth (phone OTP + custom claims) · Firestore · Storage      │
│  Security Rules = the RBAC enforcement point                 │
└──────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────────────────────┐
│  AI LAYER   Gemini · Bhashini (ULCA) · on-device fallbacks   │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│  pathashilpa_web        REACT + TS + TAILWIND (Vite)         │
│  landing · how it works · pricing · policies · press         │
│  reads the same Firestore for featured artisans (read-only)  │
└──────────────────────────────────────────────────────────────┘
```

---

# 1 · RBAC — ONE APP, FOUR ROLES

## 1.1 Roles

| Role | Set how | Can do |
|---|---|---|
| `artisan` | chosen at first login | own profile CRUD, own products CRUD, view/respond to enquiries on own products |
| `buyer` | chosen at first login | read all live products, create enquiries/RFQs, own buyer profile |
| `moderator` | set manually in console | flag/unflag products, verify artisans, take down listings |
| `dept` | set manually in console | read-only cluster analytics; no write anywhere |

For the MVP only `artisan` and `buyer` are reachable from the UI. `moderator` and `dept` exist in the model and rules so the architecture is complete and demonstrable.

## 1.2 Where the role lives

Three places, deliberately redundant:

1. **Firebase Auth custom claim** `{ role: "artisan" }` — set by a Cloud Function on first role selection. This is what Security Rules read.
2. **Firestore** `users/{uid}.role` — mirrors the claim, readable by the client for UI decisions.
3. **Local (Hive)** `session.role` — so the app knows which shell to render before the network responds. **Never trusted for authorisation.**

> MVP shortcut if Cloud Functions cost time: write the role to `users/{uid}` from the client at signup and have rules read the *document* instead of the claim. Weaker, but honest — say so if asked.

## 1.3 Enforcement layers

| Layer | What it does | Trust |
|---|---|---|
| **Route guard** (Flutter) | picks the artisan shell or buyer shell | cosmetic |
| **Widget guard** | hides buttons a role can't use | cosmetic |
| **Firestore Security Rules** | the real authority — every read/write checked | **authoritative** |
| **Storage Rules** | image uploads only under `products/{ownerUid}/` | **authoritative** |

## 1.4 Rules model (plain English, write as `.rules` later)

```
users/{uid}          read: self or moderator      write: self (role immutable after set)
artisans/{aid}       read: anyone                 write: self only
products/{pid}       read: anyone if status==live; owner always
                     create/update/delete: owner only
                     flag field: moderator only
enquiries/{eid}      create: buyer role
                     read: buyer who created it, or artisan who owns the product
                     update status: product owner only
analytics/*          read: dept role only         write: none (server writes)
```

## 1.5 Role switch UX

`role_select_screen` after OTP, once, first time only:

> **"I make things"** — मैं बनाता/बनाती हूँ
> **"I want to buy"** — मुझे खरीदना है

Stored permanently. A "switch role" option exists in settings but creates a *second* profile document — one uid can hold both roles in the model, and the app renders whichever is active.

---

# 2 · LANGUAGE — i18n + SPEECH

## 2.1 Two separate problems, don't conflate them

- **i18n** = the app's own interface strings (buttons, labels, errors)
- **Speech** = the artisan's spoken product description → text

## 2.2 i18n

- `flutter_localizations` + **ARB files**: `app_en.arb`, `app_hi.arb`, `app_bn.arb`
- Locale resolution order: user setting → device locale → `en`
- **Every artisan-facing primary button carries both languages** (English label, Hindi below it) regardless of locale — that's a deliberate design rule, not a translation gap
- Numbers, currency and dates through `intl` with the active locale
- MVP ships `en` + `hi` complete, `bn` partial as proof of extensibility

## 2.3 Speech pipeline — three tiers, degrade downward

```
TIER 1  BHASHINI (ULCA)          online · 22 languages · best accuracy
   │    ASR → (MT if needed) → text
   │    fails or offline ↓
TIER 2  DEVICE ASR               online-ish · hi-IN via speech_to_text
   │    Android's own recogniser, no key needed
   │    fails or offline ↓
TIER 3  RECORD-ONLY              fully offline
        audio saved to Hive + guided form fallback:
        craft type (picker) · material (picker) · colour (picker) · hours
        → template listing built locally
        → real transcription happens on sync
```

**The invariant:** the artisan is never blocked. Tier 3 always produces a usable draft.

## 2.4 TTS readback

- Online: Bhashini TTS
- Offline: `flutter_tts` with the device's Hindi voice
- Read aloud: the generated title, the suggested price, and the reason. Nothing else — over-narration annoys users.

---

# 3 · AI PIPELINES — every one has an offline twin

**Design rule for all five:** define an abstract interface, provide two implementations, pick at call time based on connectivity. The UI never knows which one ran.

```
abstract class XService {
  Future<XResult> run(XInput input);
}
class XOnline  implements XService { ... }   // cloud
class XOffline implements XService { ... }   // on-device / deterministic
class XRouter  implements XService {          // picks one
  run(i) => online.isAvailable ? XOnline().run(i) : XOffline().run(i)
}
```

---

## PIPELINE 1 — IMAGE

| | Online | Offline |
|---|---|---|
| Quality check | server re-validates | **OpenCV-style blur + brightness check on device** (Laplacian variance) |
| Background removal | `rembg` / cloud matting | `u2netp` TFLite (5 MB) — *MVP: skip model, use centre-crop + white pad* |
| Formatting | 2000×2000 white, 85% fill | 1200×1200 white, same rule |
| Enhancement | contrast + colour grade | CLAHE-equivalent brightness lift |

**MVP honest position:** ship the device quality-check and the crop/pad. Background removal runs online only; offline drafts show the raw photo with a "will be cleaned on sync" note.

**Output contract:** `{ imageLocalPath, imageRemoteUrl?, qualityScore, wasEnhanced: bool }`

---

## PIPELINE 2 — SPEECH → TEXT
Covered in §2.3. **Output contract:** `{ transcript, language, confidence, audioLocalPath, tier: 1|2|3 }`

---

## PIPELINE 3 — LISTING GENERATION

| | Online | Offline |
|---|---|---|
| Engine | **Gemini** structured JSON | **rule-based template fill** |
| Method | prompt in `CONTEXT.md` §8 | keyword spotting on transcript against a craft/material/colour dictionary, then fill an ARB template |
| Output | polished SEO copy, EN + HI | serviceable copy, EN + HI |

**Offline template example (structure, not final copy):**
`"{craft} {productType} in {material}"` → *"Chanderi saree in silk"*
`"Handwoven {productType} from {cluster}. Made over {hours} hours using {technique}."`

**Output contract:** `{ title, titleHi, description, descriptionHi, tags[], material, craftType, colors[], generatedBy: "gemini"|"template" }`

---

## PIPELINE 4 — PRICING

| | Online | Offline |
|---|---|---|
| Cost floor | same formula | **same formula — identical result** |
| Market band | category medians from Firestore, later a model | **cached medians JSON bundled in the app** |
| Explanation | Gemini writes the reasoning sentence | template sentence |

```
floor      = (materialCost + hours × fairWage) × overhead
suggested  = round(floor × margin, ₹50)
max        = round(suggested × 1.3, ₹50)
```

**This is the one pipeline that is identical offline and online.** That's a feature — the price an artisan sees never changes after sync. Say this in the demo.

**Output contract:** `{ floor, suggested, max, reasoning, reasoningHi, source: "cached"|"live" }`

---

## PIPELINE 5 — DISCOVERY & MATCHING *(online only, by nature)*

- Buyer text search → Firestore `array-contains-any` on `tags` (MVP)
- Roadmap: embeddings + vector search
- RFQ routing: match craft + cluster + quantity → notify matching artisans

**Offline:** not applicable. Buyers are assumed online. State this rather than pretending otherwise.

---

## PIPELINE 6 — MODERATION & PROVENANCE *(skeleton only in MVP)*

- `product.flagged` boolean + `flagReason`
- Duplicate detection: perceptual hash stored on upload, compared server-side — **interface defined, implementation stubbed**
- Provenance block is *data*, not AI: `giTag`, `cluster`, `technique`, `verifiedBy` — populated from the artisan profile, displayed on every listing

---

# 4 · OFFLINE ENGINE

## 4.1 Product state machine

```
CAPTURED ──► OFFLINE_PROCESSED ──(network)──► SYNCING ──► AI_UPGRADED ──► LIVE
                     │                                          │
              artisan can sell                            silent upgrade
              from here already                       (artisan sees no change
                                                        except better photo/copy)
```

## 4.2 Hive boxes

| Box | Holds |
|---|---|
| `session` | uid, role, locale, last sync time |
| `drafts` | full product objects awaiting sync |
| `queue` | ordered sync operations with retry count |
| `cache_products` | last-seen buyer listings for offline browsing |
| `cache_medians` | price medians JSON |
| `media` | local file paths for photos + audio |

## 4.3 Sync rules

- **Idempotency:** every draft carries a client-generated `localId` (UUID). Server upserts on `localId`, so a retry can never duplicate a product.
- **Conflict:** server wins. The server version is by definition the higher-quality version of the same record.
- **Order:** FIFO, one item at a time, exponential backoff (2s → 4s → 8s → 30s cap).
- **Payload budget:** image compressed to ≤ 300 KB, audio ≤ 100 KB, JSON small — target under 400 KB per product.
- **Trigger:** `connectivity_plus` stream + manual "Sync now" button + on app foreground.

## 4.4 What the artisan sees

- `OfflineBadge`: "Offline Draft" chip on the card
- Sync state: queued / syncing / upgraded, with a small progress line
- **Never a blocking spinner. Never an error the artisan must resolve.**

---

# 5 · DATA MODEL (additions to CONTEXT.md §6)

```
users/{uid}
  role            "artisan" | "buyer" | "moderator" | "dept"
  locale          "hi" | "en" | "bn"
  createdAt, lastSeenAt

buyers/{uid}
  name, phone, email
  buyerType       "retail" | "b2b" | "exporter" | "govt"
  company, gstin
  interests       string[]   crafts
  states          string[]
  savedProducts   productId[]

products/{pid}
  ...existing...
  localId         uuid, for idempotent sync
  state           CAPTURED|OFFLINE_PROCESSED|SYNCING|AI_UPGRADED|LIVE
  generatedBy     "gemini" | "template"
  speechTier      1 | 2 | 3
  flagged, flagReason
  perceptualHash

rfqs/{rid}
  buyerUid, craft, cluster, quantity, deadline, budgetRange
  matchedArtisanIds[], responses[]

analytics/clusters/{clusterId}      (dept role reads only)
  activeArtisans, listingsThisMonth, medianPrice, ordersFulfilled
```

---

# 6 · FLUTTER STRUCTURE — `pathashilpa_app/lib/`

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── theme/            colors.dart  typography.dart  app_theme.dart
│   ├── config/           env.dart  feature_flags.dart
│   ├── routing/          app_router.dart  route_guard.dart      ← RBAC route layer
│   ├── rbac/             role.dart  permissions.dart  guard.dart
│   ├── i18n/             l10n/app_en.arb  app_hi.arb  app_bn.arb
│   │                     locale_provider.dart
│   ├── constants/        crafts.dart  states.dart  pricing_constants.dart
│   └── utils/            validators.dart  formatters.dart  uuid.dart
│
├── data/
│   ├── models/           user.dart  artisan.dart  buyer.dart  product.dart
│   │                     enquiry.dart  rfq.dart  price_result.dart
│   │                     listing_result.dart  speech_result.dart
│   ├── local/            hive_init.dart  draft_box.dart  queue_box.dart
│   │                     cache_box.dart  session_box.dart
│   └── remote/           firestore_refs.dart  firestore_service.dart
│                         storage_service.dart  auth_service.dart
│
├── ai/                                    ← ALL PIPELINES LIVE HERE
│   ├── image/
│   │   ├── image_service.dart             abstract
│   │   ├── image_online.dart
│   │   ├── image_offline.dart             quality check + crop/pad
│   │   └── image_router.dart
│   ├── speech/
│   │   ├── speech_service.dart            abstract
│   │   ├── speech_bhashini.dart           TIER 1
│   │   ├── speech_device.dart             TIER 2
│   │   ├── speech_recordonly.dart         TIER 3
│   │   └── speech_router.dart
│   ├── listing/
│   │   ├── listing_service.dart           abstract
│   │   ├── listing_gemini.dart
│   │   ├── listing_template.dart          keyword + ARB template
│   │   └── listing_router.dart
│   ├── pricing/
│   │   ├── pricing_service.dart           one implementation, works everywhere
│   │   └── median_cache.dart
│   ├── discovery/
│   │   └── search_service.dart            online only
│   ├── moderation/
│   │   └── moderation_service.dart        stubbed
│   └── tts/
│       ├── tts_service.dart  tts_bhashini.dart  tts_device.dart
│
├── sync/
│   ├── connectivity_service.dart
│   ├── sync_engine.dart                   FIFO + backoff + idempotency
│   ├── sync_state.dart
│   └── conflict_resolver.dart             server-wins
│
├── features/
│   ├── auth/             splash · role_select · phone_login · otp
│   ├── artisan/
│   │   ├── onboarding/   voice-guided profile creation
│   │   ├── home/         dashboard
│   │   ├── profile/      view + edit
│   │   ├── products/     list + detail
│   │   ├── add_product/  step1_photo · step2_voice · step3_costs · step4_review
│   │   └── enquiries/
│   ├── buyer/
│   │   ├── explore/      grid + filters
│   │   ├── product/      detail + enquiry + RFQ
│   │   ├── artisan/      public storefront
│   │   ├── profile/      buyer profile
│   │   └── enquiries/    sent enquiries
│   ├── moderator/        flagged_queue  (stub screen, proves RBAC)
│   └── dept/             cluster_dashboard  (stub screen, proves RBAC)
│
└── widgets/
    ├── buttons/          primary_button (EN+HI)  voice_button  icon_action
    ├── cards/            product_card  artisan_card  enquiry_card
    ├── product/          price_band_card  provenance_block  status_chip
    ├── feedback/         offline_badge  sync_indicator  empty_state
    └── layout/           app_shell  bottom_nav_artisan  bottom_nav_buyer
```

---

# 7 · REACT WEB STRUCTURE — `pathashilpa_web/src/`

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

---

# 8 · WHAT'S REAL vs STUBBED IN THE MVP

| Capability | MVP status |
|---|---|
| Phone OTP auth | ✅ real (mock OTP fallback) |
| Role selection + route guards | ✅ real |
| Firestore Security Rules | ✅ real |
| i18n EN + HI | ✅ real |
| Speech Tier 2 (device) | ✅ real |
| Speech Tier 1 (Bhashini) | 🟡 if ULCA key arrives in time |
| Speech Tier 3 (record + form) | ✅ real |
| Image quality check + crop/pad | ✅ real |
| Background removal | 🟡 online only |
| Gemini listing generation | ✅ real |
| Template listing (offline) | ✅ real |
| Pricing (both tiers) | ✅ real |
| Offline draft + sync engine | ✅ real — **this is the demo** |
| Buyer browse + enquiry | ✅ real |
| RFQ | 🟡 form saves, no matching |
| Moderator / dept screens | ⬜ stub screens, real rules |
| GeM / ONDC publish | ⬜ mocked status chip, labelled as such |
| Payments | ⬜ out of scope |

---

# 9 · BUILD ORDER

**Foundation (first, together)** — models · Hive init · Firestore refs · theme · ARB files · role enum + guard. Nothing else starts until `models/` and `firestore_service` signatures are agreed.

**Then, in parallel**
- **A:** `ai/` routers + `sync/` engine → `add_product/` four steps
- **B:** auth + role select + artisan home/profile/products
- **C:** buyer explore/product/profile/enquiries
- **D:** React web + seed data + demo video

**Last:** moderator/dept stubs (30 min, big credibility payoff — they prove the RBAC is architectural, not cosmetic).

---

# 10 · THE DEMO SCRIPT THIS ARCHITECTURE ENABLES

1. Open app → choose "I make things"
2. **Turn on airplane mode**
3. Photograph the saree → speak in Hindi → enter cost and hours
4. Listing appears with title, description and price — **"Offline Draft"** badge visible
5. Turn network back on → badge changes to syncing → photo sharpens, copy improves, price unchanged
6. Switch to buyer mode → find the product → read the maker's story → send an enquiry
7. Back to artisan → enquiry has arrived, read aloud in Hindi

Step 2 is the moment that wins it. Rehearse it until it is boring.
# PATHASHILPA — PRODUCT REQUIREMENTS DOCUMENT

**Version** 1.1 · MVP
**Problem Statement** AI-Driven Market Linkage and Smart Cataloging Mobile Application for Marginalized Artisans
**Category** Software · Smart India Hackathon 2026
**Companion documents** [`TRD.md`](TRD.md) (how it is built) · [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) (single source of truth for build agents)

---

> **Repository scope:** this repo builds the **Flutter application only** — specifically the **artisan role**. The buyer role is owned by a separate contributor (see §5.6). No marketing website is built here.

---

## 1 · SUMMARY

Pathashilpa converts **a photograph and a spoken sentence** into a complete, priced, published product listing for a rural Indian artisan.

The artisan performs three actions: photograph the product, speak about it, confirm. The system removes the background, writes the title, description and tags in English and Hindi, calculates a fair price with its reasoning, and publishes to a public storefront — working fully offline and upgrading silently when the network returns.

**Positioning:** Not another marketplace. The layer that *creates* the listing other marketplaces require.

**Tagline:** Your craft. Your price. Your name.

---

## 2 · THE PROBLEM

### 2.1 Statement

A marketplace listing requires four artefacts: **a clean photograph, English product copy, a defensible price, and completed registration forms.** Rural artisans can produce none of them. Every existing platform — Amazon Karigar, Flipkart Samarth, ONDC, IndiaHandmade — begins *after* those four exist. The artisan reaches "Create Listing" and stops.

### 2.2 Evidence *(only these figures may be used in any material)*

| Figure | Meaning | Source |
| :---- | :---- | :---- |
| **0.2%** | share of handloom sales occurring online | 4th All India Handloom Census, via India Development Review |
| **95.5%** | rural mobile owners who own a smartphone | NSO, Comprehensive Modular Survey: Telecom, 2025 |
| **67%** | handloom households earning under ₹5,000/month | PIB, Ministry of Textiles |
| **≈ ₹270/day** | average handicraft artisan earnings | IHD & Crafts Council of India |
| **~20% / >90%** | artisans with digital-selling training / who want it | Digital Empowerment Foundation, via IDR |
| **35.2 lakh** | handloom weavers + allied workers | PIB, Ministry of Textiles |
| **7,104 → 5,134** | mn sq m handloom output, 2013-14 → 2017-18 | Economic & Political Weekly |

### 2.3 The insight

**0.2% online against 95.5% smartphone ownership.** The device barrier is already gone. What is missing is software the artisan can operate.

### 2.4 Deliberately excluded

No credible government or peer-reviewed source exists for *middleman margin share* or *counterfeit handloom volume*. Both are referenced qualitatively only, never as statistics.

---

## 3 · USERS

### 3.1 Primary — the artisan

**Kamala, 42, Chanderi, Madhya Pradesh.** Weaves silk sarees; takes two weeks per piece. Owns a ₹7,000 Android phone, uses WhatsApp voice notes daily, does not type. Speaks Hindi and Bundeli; reads Hindi slowly, no English. Sells to a trader who visits monthly, and at two melas a year. Network drops for hours at a time.

**What she needs:** to sell without learning anything, without typing, and without waiting for the trader.
**What blocks her today:** she cannot photograph, describe, price or register.

### 3.2 Secondary — the buyer

**Retail buyer** — wants authenticity and the maker's story. **B2B buyer / exporter** — wants bulk quantity, consistent quality, verified provenance, direct contact. **Institutional buyer** — procures through GeM, needs GI verification and compliance.

### 3.3 Supporting

**Moderator** — verifies artisans, removes counterfeit listings. **Department / NGO** — onboards clusters, monitors cluster income and output.

---

## 4 · VALUE PROPOSITION

| Actor | Before | With Pathashilpa |
| :---- | :---- | :---- |
| Artisan | Cannot create a listing at all | A live listing in ~90 seconds, by speaking |
| Artisan | Prices by guesswork, undersells | Cost floor + explained market band |
| Artisan | Anonymous product on a shelf | Face, story, cluster and GI tag on every listing |
| Artisan | Capital locked in unsold stock | Produces only against confirmed orders |
| Buyer | Cannot verify what is handmade | Provenance block tied to verified identity |
| Department | Annual paper returns | Live cluster output and income data |

### The five differentiators

1. **Offline-first AI** — a complete listing with zero internet
2. **Voice-only workflow** — no typing at any step
3. **Explained pricing** — shows *why*, not just the number
4. **Story as listing data** — maker and GI tag travel with every product
5. **One record, all channels** — storefront, GeM and ONDC together

---

## 5 · SCOPE

### 5.1 MVP — must ship

- Phone OTP authentication with role selection (artisan / buyer)
- Artisan: voice-guided onboarding, profile, product list, **four-step add-product flow**
- AI: image quality check + crop/pad, speech-to-text, listing generation (EN + HI), price calculation
- **Offline draft creation + sync engine with silent upgrade**
- Buyer: browse, filter, product detail, artisan storefront, enquiry, RFQ form — *separate contributor, see §5.6*
- Firestore Security Rules enforcing RBAC

### 5.2 Mocked, and labelled as mocked

- GeM / ONDC publishing → status chip only
- KYC verification → document upload without verification
- Payments → "Enquire" instead of "Buy"
- Moderator and department screens → stubs behind real rules

### 5.3 Roadmap, not MVP

Credit scoring from sales history · export enablement (HS codes, IEC) · cluster co-operative pooled fulfilment · all 22 Bhashini languages · department dashboards · ML pricing trained on realised sales · **on-device ML models** (see §5.5)

### 5.4 Explicit non-goals

Not a logistics company. Not a payment aggregator. Not a competitor to ONDC — a participant in it. Not a training programme.

### 5.5 On-device ML — explicitly deferred

Earlier drafts named **Vosk** (offline Indic ASR), **MobileNetV3** (on-device image quality) and **CLIP** (zero-shot tagging). All three are **out of MVP**: each requires bundling a model file, which breaks the ≤ 40 MB APK budget and the "no bundled ML models in MVP" rule in [`TRD.md`](TRD.md) §12.

The MVP achieves the same offline guarantees without them:
- Offline ASR → Android's own recogniser via `speech_to_text` (Tier 2), then record-and-form (Tier 3)
- Offline image quality → classical Laplacian blur/brightness check + centre-crop and white pad
- Tagging → derived from the transcript by the template engine, or from Gemini's structured output when online

### 5.6 Repository and ownership scope

This repository builds the **Flutter application only**, and within it the **artisan role**.

| Area | Owner | In this repo |
| :---- | :---- | :---- |
| Shared foundation — theme, fonts, i18n, shared widgets, routing | this workstream | ✅ yes |
| Artisan role — onboarding, profile, products, add-product flow, enquiries received | this workstream | ✅ yes |
| AI routers, offline engine, sync | this workstream | ✅ yes |
| **Buyer role** — explore, product detail, enquiry, RFQ, buyer profile | **separate contributor** | ✅ same repo, not this workstream |
| **Marketing website** | — | ❌ **not built here** |

**One binary, two shells** ([`TRD.md`](TRD.md) AD-3) — both roles ship in the same app, so the shared foundation is a contract between the two workstreams and must not be changed unilaterally. `BuyerShell` exists as the buyer workstream's entry point; `features/buyer/` is left to that contributor.

The React marketing site is **out of scope for this repository entirely**. It is not deferred work here and should not appear in any build status as pending.

---

## 6 · KEY USER JOURNEY — the add-product flow

**Step 1 · Photo** — camera opens, artisan shoots, device checks blur and brightness, shows preview with retake option.
**Step 2 · Voice** — large mic button, artisan speaks in Hindi, live transcript appears.
**Step 3 · Costs** — two large numeric inputs: material cost, hours of work.
**Step 4 · Review** — cleaned image, generated title/description/tags, price band with reasoning read aloud. One button: Publish.

**Offline behaviour:** steps 1–4 complete with no network. The listing is marked *Offline Draft* and is already sellable. On reconnect it syncs, the image is re-rendered, the copy is upgraded — **and the price does not change.**

---

## 7 · FUNCTIONAL REQUIREMENTS

Feature module IDs are referenced by the build agents and by [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md).

### `FEAT-01` — Authentication & Role Selection
- Phone number input with Firebase Phone OTP (`firebase_auth.verifyPhoneNumber`)
- Role selection screen on first login: "I make things" (मैं बनाता/बनाती हूँ) vs "I want to buy" (मुझे खरीदना है)
- Write role to `users/{uid}` (**immutable after first write**), mirror to Hive `session` box for fast shell routing
- Role stored as Auth custom claim; Security Rules are the authoritative enforcement layer

### `FEAT-02` — Four-Step Add-Product Workflow
- **Step 1 Visual Capture** — camera/gallery; on-device Laplacian blur & brightness check; offline centre-crop + 1200×1200 white pad. Online upgrade: fal.ai background removal + enhancement
- **Step 2 Vernacular Voice** — online Sarvam AI → Bhashini ULCA; offline device ASR (Tier 2) → record + guided attribute picker (Tier 3)
- **Step 3 Cost & Time** — raw material cost (₹) and labour hours
- **Step 4 Review & Pricing** — bilingual title/description (Gemini online, template offline); floor/suggested/max price with Hindi rationale; TTS readback; artisan adjusts and confirms `priceFinal`

### `FEAT-03` — Offline Engine & Idempotent Sync
- Draft saved to Hive `drafts` box with client UUID `localId`
- "Offline Draft" badge on the artisan home screen
- Auto-sync worker on the `connectivity_plus` stream; upload compressed media; upsert `products/{localId}`; AI upgrade **without altering confirmed `priceFinal`**
- State progression `CAPTURED → OFFLINE_PROCESSED → SYNCING → AI_UPGRADED → LIVE`

### `FEAT-04` — Buyer Exploration & Enquiries — *separate contributor*
> Owned by another contributor, not built in this workstream. Specified here because the artisan side consumes its output: `FEAT-02` produces the listings it reads, and enquiries it creates surface in the artisan's inbox.

- Filter by craft type, region, price, tags
- Artisan story and provenance block (`giTag`, `cluster`, `technique`, `verifiedBy`)
- Enquiry submission (`quantity`, `message`) → `enquiries/{enquiryId}` with real-time artisan alerts
- RFQ creation form for custom bulk orders

### Cross-cutting rules
**AI services** — each pipeline is an abstract interface with an online and an offline implementation plus a router that selects by connectivity. The UI never knows which ran.
**Sync engine** — client-generated `localId` for idempotency; FIFO queue; exponential backoff; server-wins conflict rule; payload target under 400 KB per product.
**Pricing** — `floor = (materialCost + hours × ₹150) × 1.15`; `suggested = round(floor × 1.25, ₹50)`; `max = round(suggested × 1.3, ₹50)`. Identical online and offline. The artisan may always override.

---

## 8 · NON-FUNCTIONAL REQUIREMENTS

| Area | Requirement |
| :---- | :---- |
| Device | Android 8+, 2 GB RAM, ₹6,000 handset class |
| Offline | Full add-product flow functional with no network |
| Payload | ≤ 400 KB per product sync |
| Accessibility | ≥ 16px text, ≥ 56px tap targets, icon beside every label |
| Language | English + Hindi complete; Bengali partial |
| Privacy | Voice recordings deletable by the artisan; DPDP Act 2023 aligned |
| Data ownership | Artisan can export or delete all their data |

---

## 9 · SUCCESS METRICS

**Primary:** listing completion rate — % of artisans who start the add-product flow and publish. Target **> 80%**, against a manual-marketplace baseline near zero.

**Supporting:** time to first listing (target < 3 minutes) · listings created offline (proves the thesis) · artisan retention at 30 days · enquiries per listing · realised price vs cost floor.

---

## 10 · BUSINESS MODEL

- **Revenue** — commission on B2B orders; paid RFQ access for exporters and institutional buyers
- **The artisan pays nothing**, ever, and gives up no margin
- **Operating cost** — Bhashini, ONDC and GeM are free public infrastructure; one AI call per listing, not per view
- **Distribution** — Development Commissioners, NGOs and co-operatives are already funded to reach these clusters; acquisition cost is zero
- **Defensibility** — realised artisan sale prices compound into a pricing dataset no competitor can buy

---

## 11 · RISKS

| Risk | Mitigation |
| :---- | :---- |
| Artisan distrusts an AI price | Reasoning read aloud; artisan can override; cost floor blocks loss-making sales |
| Weak network, low-end devices | Offline-first; ≤ 400 KB syncs; self-resuming retries |
| No sales history to price against | Deterministic cost floor from day one; seed medians from public listings; retrain on realised sales |
| Sellers without buyers | Publish into GeM and ONDC where buyers already are; onboard buyers before mass artisan onboarding |
| Speech fails on dialects | Sarvam → Bhashini → device ASR → record-and-form fallback; raw audio always retained |
| Counterfeit listings | Provenance block tied to verified identity; perceptual-hash duplicate detection; moderator takedown |

---


---

## 12 · OPEN QUESTIONS

1. Registered team and product name — must match the deck exactly
2. Which GI cluster is the pilot — Chanderi assumed throughout
3. Whether the Bhashini ULCA key arrives before the demo
4. How the APK reaches artisans and evaluators for the demo

# PATHASHILPA — PRODUCT REQUIREMENTS DOCUMENT

**Version** 1.1 · MVP
**Problem Statement** AI-Driven Market Linkage and Smart Cataloging Mobile Application for Marginalized Artisans
**Category** Software · Smart India Hackathon 2026
**Companion documents** [`TRD.md`](TRD.md) (how it is built) · [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) (single source of truth for build agents)

---

# PART A — THE PRODUCT

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
- Buyer: browse, filter, product detail, artisan storefront, enquiry, RFQ form
- Firestore Security Rules enforcing RBAC
- Public marketing website with policies

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

### `FEAT-04` — Buyer Exploration & Enquiries
- Filter by craft type, region, price, tags
- Artisan story and provenance block (`giTag`, `cluster`, `technique`, `verifiedBy`)
- Enquiry submission (`quantity`, `message`) → `enquiries/{enquiryId}` with real-time artisan alerts
- RFQ creation form for custom bulk orders

### `FEAT-05` — Web Public Showcase
- React + Vite + Tailwind marketing site reading public Firestore collections (`products`, `artisans`)
- Artisan stories, cluster heritage, craft preservation

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

# PART B — LANDING PAGE SPECIFICATION

**Stack:** React + TypeScript + Tailwind (Vite) · deployed on Vercel
**Audience order:** SIH evaluators → artisans and their field partners → buyers

> **Note on visual identity:** the palette and type below apply to the **marketing website only**. The Flutter application uses a separate approved palette and font stack — see [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) §6. These two systems are currently divergent and should be reconciled before launch.

---

## 12 · INFORMATION ARCHITECTURE

```
/                     Home
/how-it-works         Artisan journey + buyer journey
/pricing              Free for artisans · buyer plans · the pricing formula, openly
/for-artisans         Benefits, FAQ, download CTA
/for-buyers           Provenance, GI verification, bulk RFQ
/about                Mission, the 0.2% story, team
/press                Sample coverage (labelled)
/press/:slug          Article
/privacy              Privacy Policy
/terms                Terms of Service
/refund-policy        Returns & Refunds
/artisan-charter      Six commitments to artisans
/contact              Form + addresses
```

**Header:** logo · How it works · For artisans · For buyers · Pricing · About · `[Explore crafts]` primary CTA
**Footer:** four columns — Product / For artisans / Company / Legal · language toggle EN·हिं · "Built for Smart India Hackathon 2026"

---

## 13 · DESIGN SYSTEM — marketing website

```css
--ink        #1A1A1A     --paper      #FDFBF7
--card       #FFFFFF     --border     #E5E0D8
--primary    #8B3A2F     --primary-2  #A8503F     /* terracotta */
--accent     #1F4E5F                              /* deep teal */
--success    #2F6E4A     --warn       #A9761B     --muted #7A736B
```

Display `"Fraunces", Georgia, serif` · Body `"Inter", system-ui, sans-serif` · Mono `"IBM Plex Mono"`

Radius 8px cards / 999px pills · Shadow `0 1px 3px rgba(0,0,0,.06)` · Container `max-w-6xl` · Section padding `py-20 md:py-28`

**Rule:** warm paper background, terracotta used sparingly for action only, generous whitespace. Craft photography carries the colour — the interface stays quiet.

---

## 14 · HOME PAGE — SECTION BY SECTION

### 14.1 Hero
- **H1:** Your craft. Your price. Your name.
- **Sub:** Pathashilpa turns a photograph and a spoken sentence into a live, fairly priced listing — in about ninety seconds, even with no internet.
- **CTAs:** `Explore crafts` (primary) · `For artisans` (ghost)
- **Visual:** phone mockup showing the review screen — cut-out saree, Hindi title, ₹2,850 price chip
- **Trust line:** Built on Bhashini · Publishes to GeM and ONDC

### 14.2 Stat strip — four tiles
`0.2%` of handloom sales happen online · `95.5%` of rural mobile owners have a smartphone · `67%` of handloom households earn under ₹5,000/month · `35.2 lakh` weavers and allied workers. *Source line beneath, small.*

### 14.3 The insight band *(full-width, dark)*
> The phone is already in their hand. What's missing is software they can use.

### 14.4 How it works — 3 columns
**Photograph it** — Point the camera. The app cleans the background and fixes the lighting.
**Speak about it** — Describe the piece in your own language. The AI writes the listing in English and Hindi.
**It goes live** — A fair price with its reasoning, then published to your storefront, GeM and ONDC.
*Footnote: All three steps work with no internet. The listing improves silently when you reconnect.*

### 14.5 What makes it different — 5 cards
Offline-first AI · Voice-only workflow · Explained pricing · Story as listing data · One record, all channels

### 14.6 Featured artisans — 3 cards
Photo, name, craft, cluster, one line of story, "View their work"

### 14.7 Comparison table
Condensed capability matrix — 6 rows, Pathashilpa column highlighted. Link: *See the full comparison*

### 14.8 For artisans / For buyers — split band
Two panels, each with three bullets and a CTA.

### 14.9 Closing CTA
> Every rival starts at the server. We start in the artisan's hand.

`Explore crafts` · `Partner with us`

---

## 15 · OTHER PAGES — required content

**How it works** — 5-step artisan journey (Register · Capture · AI Studio · Speak · Publish) with screenshots; 3-step buyer journey; an offline explainer diagram showing which steps need no network.

**Pricing** — "Free for artisans, forever" panel with the six things that cost nothing; buyer plans table (Retail free / B2B monthly / Institutional custom); **the fair-price formula shown openly** with a worked example; FAQ.

**For artisans** — the six benefits, the 90-second promise, "what you need" (a phone, that's all), FAQ in Hindi and English, download CTA.

**For buyers** — how provenance works, what GI verification means, the RFQ process, why made-to-order.

**About** — the 0.2% story, mission, team, partners, SIH context.

**Artisan Charter** *(differentiator — write it carefully)* — six commitments: the artisan never pays · the suggested price is never below the cost floor · they can override any price · their story stays attached to their product · they can export or delete all their data · we never sell artisan data.

**Legal** — Privacy (voice recordings, Gemini/Firebase as processors, deletion rights, DPDP Act 2023) · Terms (artisan owns listings and images; price is advisory; enquiries are not binding; listing machine-made goods as handmade is prohibited) · Refunds (made-to-order binding on acceptance; transit damage; return shipping).

**Press** — 5–6 sample article cards. **Add a visible line: "Sample coverage shown for demonstration purposes."** Do not present fabricated articles as real reporting.

---

## 16 · ASSETS REQUIRED

**Photography** — 9–12 craft product shots (sarees, ikat, toys, pottery) · 3 artisan portraits · 2 workshop/loom context shots. Use own photos or clearly-licensed stock; record attributions.

**Graphics** — logo (wordmark + PS monogram) · phone mockup frame · offline/online flow diagram · comparison table graphic · favicon.

**Copy** — all section text above · 3 artisan stories (2–3 sentences each) · 5–6 mock articles · FAQ set · complete legal text.

---

## 17 · SEO & META

- Title: `Pathashilpa — Your craft. Your price. Your name.`
- Description: `An AI app that turns a photo and a voice note into a live, fairly priced listing for Indian artisans. Works offline. Publishes to GeM and ONDC.`
- OG image 1200×630 with the hero line
- Semantic headings, alt text on every image, `lang` attribute switching with the locale toggle

---

## 18 · ACCEPTANCE CRITERIA

- [ ] Loads under 2s on 4G; Lighthouse performance ≥ 85
- [ ] Fully responsive 360px → 1440px
- [ ] Every statistic carries its source
- [ ] All legal pages complete, not placeholder text
- [ ] Mock articles visibly labelled as samples
- [ ] No unverified statistic appears anywhere
- [ ] Colour contrast passes AA
- [ ] All CTAs reach a real destination

---

## 19 · OPEN QUESTIONS

1. Registered team and product name for the portal — must match the deck exactly
2. Which GI cluster is the pilot — Chanderi assumed throughout
3. Whether the Bhashini ULCA key arrives before the demo
4. Domain name for deployment
5. Whether the artisan app ships as an APK download link on the site
6. **Whether the marketing palette (§13) and the app palette (`PROJECT_CONTEXT.md` §6) should be unified** — they are currently two unrelated colour systems

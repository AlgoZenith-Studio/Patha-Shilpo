# Patha-Shilpa (পাথ-শিল্প / पथ-शिल्प)

> **Offline-First, Voice-Guided Rural Artisan Listing & Fair Pricing Platform**

---

## 📌 Quick Reference & Documentation Index

- **Product Requirements & Architecture Context**: [AI_COWORKER/shared_memory/final_project_context.md](file:///c:/Users/USER/Desktop/Patha-Shilpo/AI_COWORKER/shared_memory/final_project_context.md)
- **PRD Specification**: [AI_COWORKER/shared_memory/prd/PRD.md](file:///c:/Users/USER/Desktop/Patha-Shilpo/AI_COWORKER/shared_memory/prd/PRD.md)
- **MVP Architecture & Offline Engine**: [mvp.md](file:///c:/Users/USER/Desktop/Patha-Shilpo/mvp.md)
- **Technical Requirements Document (TRD)**: [TRD.md](file:///c:/Users/USER/Desktop/Patha-Shilpo/TRD.md)

---

## 🏗️ Core AI & Tech Stack

| Layer | Offline / On-Device | Online / Cloud |
| :--- | :--- | :--- |
| **Visual Processing** | MobileNetV3 + 1200x1200 white crop/pad | RMBG-1.4 (Background Removal via fal.ai) + Real-ESRGAN (Upscaling via fal.ai) + CLIP (Zero-shot Tagging) |
| **Voice & Speech** | Vosk (On-device Indic ASR) + Tier 3 record fallback | Sarvam AI + Bhashini ULCA (ASR, MT, Indic TTS) |
| **Listing Generation** | Rule-based ARB template fill | Gemini 2.0 Flash structured JSON |
| **Pricing Engine** | Deterministic fair-wage formula + cached medians | Live Firestore category medians |
| **Client Apps** | Flutter (Android app) with Hive storage & dual role shells | React 18 + Vite + Tailwind (Web public showcase) |
| **Backend & RBAC** | Local Hive queue (`drafts`, `queue`, `session`) | Firebase Auth (Phone OTP), Firestore, Cloud Storage, Security Rules |

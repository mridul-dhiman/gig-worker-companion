# CLAUDE.md — Saathi AI: Gig Worker Companion (PromptWars / Build with AI)

## 1. Challenge Mission & Core Pillars
Design and build a GenAI-powered assistant ("Saathi AI") that supports gig and informal workers such as delivery partners, drivers, and daily-wage workers. Generative AI operates as a core component to provide multilingual guidance in simple, zero-jargon language across five interconnected pillars:
1. **Earnings Tracking (`earnings`)**: Parse natural-language voice/text shift logs into structured Gross, Expense, Deduction, and Net Take-Home metrics, flagging unfair platform penalties or unpaid wages.
2. **Grievance & Dispute Drafting (`grievance`)**: Generate both a plain-language explanation for the worker and a formal, ready-to-send complaint for platform support, contractors, labour officers, or traffic courts.
3. **Rights & Welfare Scheme Awareness (`welfare`)**: Match the worker's occupation and monthly net income to central/state schemes (e-Shram, PM-SYM, State Gig Worker Welfare Boards) and summarize statutory rights.
4. **Document Help (`documents`)**: Decode complex penalty notices, traffic e-challans, contractor slips, and KYC rejection notices into 3 actionable next steps.
5. **Safety Practices (`safety`)**: Provide role-specific safety checklists and weather/hazard ID-protection rules so workers can pause work during emergencies without automated account blocking.

## 2. Evaluation Resilience & Connected Workflows
- **Thoughtfully Connected Workflows**: Every module passes context directly to downstream tabs via explicit "Next Step" CTA buttons:
  - *Earnings Tracker* -> **"Contest ₹X Deduction in Grievance Drafter"** (pipes flagged deduction into `disputeInput`).
  - *Earnings Tracker* -> **"Check Eligible Welfare Schemes"** (uses calculated monthly net income).
  - *Rights & Welfare* -> **"Get Document Help for This Scheme"** (pipes scheme KYC checklist into Document Simplifier).
  - *Document Help* -> **"Draft Formal Reply / Dispute for This Notice"** (pipes decoded notice into Grievance Drafter).
  - *Safety Practices* -> **"Report Unsafe Work Condition"** (pipes weather/site hazard into Grievance Drafter).
- **Zero-Crash Fault Tolerance**:
  - Pre-loaded worker personas (*Rajesh - Delivery Partner*, *Gurpreet - Cab Driver*, *Sunita - Daily-Wage Worker*) initialize all 5 modules with realistic state so evaluators can test tabs in any order.
  - All Gemini API calls use structured JSON (`responseMimeType: "application/json"`) with exponential backoff AND a deterministic multilingual fallback engine so network blips never break evaluation flows.

## 3. Tech Stack & Commands
- **Framework**: Flutter (web target for submission), Material 3, `ChangeNotifier` state, `google_fonts` (Baloo 2 / Mukta, Gurmukhi variants for Punjabi). The old React stub lives in `_legacy_react/`.
- **LLM Model**: `gemini-3-flash-preview` via Google Generative Language REST API (`lib/services/gemini_client.dart`)
- **Accounts**: one worker per login. Sign-up asks language, phone + OTP (demo code `482913`; Firebase phone auth slots in later), work type, then name/age/state. Work type decides every tab's content.
- **Storage**: `shared_preferences` (browser localStorage on web) for profile, cash entries, SMS entries, daily take-home history and checklist ticks.
- **Run Locally** (Flutter SDK at `~/development/flutter/bin`):
  ```bash
  flutter pub get
  flutter run -d chrome --dart-define=GEMINI_API_KEY=your_key
  flutter test
  flutter build web --release --dart-define=GEMINI_API_KEY=your_key   # output: build/web
  ```
  The key can also be entered at runtime in the profile sheet. With no key, the fallback engine answers everything.
- **Web limits**: SMS is pasted, not read from the inbox (Android-only feature). Photos/screenshots use `image_picker`; Gemini reads them.

## 4. Prompt Engineering Rules
- Always inject active `language` (`English`, `Hindi (हिंदी)`, `Punjabi (ਪੰਜਾਬੀ)`, `Hinglish`) and `persona.role` into `systemInstruction`.
- Enforce 5th-grade reading simplicity, empathy, and actionable steps.
- Never output raw legal jargon without an accompanying plain-language worker translation.

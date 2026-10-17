# Saathi AI — Gig Worker Companion

Built for the **Google for Developers — PromptWars (Build with AI)** Warm-up Challenge.

A Flutter web app that helps delivery partners, drivers and daily-wage workers track their real take-home, contest unfair cuts, find welfare schemes, understand notices, and stay safe. Answers come in English, Hindi, Punjabi or Hinglish.

## Run it

```bash
flutter pub get
flutter run -d chrome --dart-define=GEMINI_API_KEY=your_key
```

Build for hosting (the output is a static site in `build/web`):

```bash
flutter build web --release --dart-define=GEMINI_API_KEY=your_key
```

No key? The app still works end to end on its built-in rule engine. You can also paste a key later from the profile button (top right).

## Try it

1. Sign up: pick a language, enter any 10-digit mobile number starting 6–9, and use the demo OTP **482913**. Choose a work type; sample details fill in and can be edited.
2. **Earnings**: work out today's take-home, add cash you got or spent, and paste a bank SMS (or tap *Try sample SMS*). A payout SMS with a cut gets a **Dispute** button.
3. Follow the marigold buttons. Each one carries details into the next tab: Earnings → Complaint, Earnings → Schemes, Schemes → Papers, Papers → Complaint, Safety → Complaint.
4. **Complaint**: attach a photo or screenshot and Saathi reads the facts out of it.
5. Profile → *Simulate network failure* shows the retry-then-fallback path.

## Layout

| Path | What it holds |
|---|---|
| `lib/services/gemini_client.dart` | REST call, JSON schema output, exponential backoff |
| `lib/services/saathi_ai.dart` | One method per pillar, Gemini first, fallback second |
| `lib/services/fallback_engine.dart` | Offline parser for logs, notices, SMS; complaint templates |
| `lib/data/professions.dart` | Per-work-type content and scheme rules |
| `lib/state/app_state.dart` | Signed-in worker's state, hand-offs between tabs, storage |
| `lib/ui/` | Sign-up, shell and the five tabs |
| `test/` | Parser, scheme, retry and end-to-end flow tests |

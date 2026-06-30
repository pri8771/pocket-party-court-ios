# Pocket Party Court ⚖️

Pocket Party Court is a funny, offline iOS party game where friends put silly
disputes on trial, argue their sides, vote locally, and generate a shareable
verdict card — all on one phone. No backend, no login, no account, no tracking.

## What you do

1. **Pick a deck** — Friend Court, Family Tribunal, Office Chaos Court (work-safe), or Date Night Court.
2. **Set the stage** — add 2–8 players; roles (judge, plaintiff, defendant, jury) are assigned automatically.
3. **Reveal the case** — a silly charge with argument hints for each side.
4. **Argue** — a shared countdown keeps the room moving (pause / +30s / skip).
5. **Vote** — the jury (and judge) decide; the two litigants argue, everyone else votes.
6. **Read the verdict** — Guilty, Not Guilty, or Hung Jury, with a confetti reveal and a privacy-safe, shareable verdict card.
7. **Keep playing** — Next Case, New Round (rotates roles), or end the game.

A full case takes about five minutes.

**Status: feature-complete v1, ~80–90% production-ready.** The full game ships: a restart-safe,
multi-case state machine with per-case scoring, a "crown the winner" finale, and dynamic add/drop of
players. The canonical launch scope, MVP feature status, bug triage, and production-readiness
checklist live in [`LAUNCH_READINESS.md`](LAUNCH_READINESS.md).

## Principles

- **Local-only** gameplay — no backend, login, cloud sync, or network requirement.
- **Privacy by design** — verdict cards never include who voted which way; history stays on device.
- **No monetization in v1** — fully free with four bundled decks; no ads, no subscriptions, no IAP. (Deck packs are a documented *future* model; `StoreService` is an inert stub.)
- Apple frameworks only: **Swift, SwiftUI, SwiftData**. iOS 17+.

## Architecture

Feature-based MVVM with a small, pure state machine at the core.

- `Sources/Core/Engine` — `GameStore` (the full-case state machine), `VerdictEngine` (pure three-way tally), `JuryRules` (role/voter assignment). UI- and SwiftData-free, so it is fully unit-testable.
- `Sources/Core/Models` — SwiftData `@Model` entities (`CaseDeck`, `GameCase`, `GameSession`, `Player`) and the `Verdict` enum.
- `Sources/Core/DesignSystem` — the "playful courtroom" design language: colors, typography, components, gavel mark, countdown ring, verdict stamp, confetti.
- `Sources/Core/Services` / `Analytics` / `Monetization` — deck seeding, privacy-safe sharing, local analytics, and an inert `StoreService` stub (future deck packs).
- `Sources/Features` — Home, Game (setup → reveal → arguments → voting → verdict), Decks + paywall, History, About.
- `Sources/Resources` — bundled starter decks + asset catalog (app icon, accent color).
- `Tests/PocketPartyCourtTests` — engine, jury, verdict, share-privacy, seeding, and history tests.

See `Docs/Engineering/Architecture.md` for details.

## Setup

1. Open `PocketPartyCourt.xcodeproj` in Xcode 16 or newer.
2. Select an iOS 17+ simulator or device.
3. Build and run the `PocketPartyCourt` scheme.

### Command line

```bash
xcodebuild -project PocketPartyCourt.xcodeproj -scheme PocketPartyCourt \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

xcodebuild -project PocketPartyCourt.xcodeproj -scheme PocketPartyCourt \
  -destination 'platform=iOS Simulator,name=iPhone 17' test
```

CI (`.github/workflows/ci.yml`) runs the same build + tests on `macos-latest`,
selecting an available simulator automatically.

## Status

v1 is feature-complete and ~82% production-ready (full status and the build-to
checklist live in [`LAUNCH_READINESS.md`](LAUNCH_READINESS.md)). The remaining
work is App Store assets (screenshots, hosted privacy-policy URL, final privacy
questionnaire), a formal accessibility audit, and the cold-group play test. v1
ships no monetization; live StoreKit deck packs are a documented *future* item.
See `Docs/ProjectManagement/Status_Report.md`.

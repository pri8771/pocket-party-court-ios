# Pocket Party Court ⚖️

Pocket Party Court is a funny, offline iOS party game where friends put silly
disputes on trial, argue their sides, vote locally, and generate a shareable
verdict card — all on one phone. No backend, no login, no account, no tracking.

## What you do

1. **Pick a deck** — Friend Court, Family Tribunal, Office Chaos Court (work-safe), or the premium Date Night Court.
2. **Set the stage** — add 2–8 players; roles (judge, plaintiff, defendant, jury) are assigned automatically.
3. **Reveal the case** — a silly charge with argument hints for each side.
4. **Argue** — a shared countdown keeps the room moving (pause / +30s / skip).
5. **Vote** — the jury (and judge) decide; the two litigants argue, everyone else votes.
6. **Read the verdict** — Guilty, Not Guilty, or Hung Jury, with a confetti reveal and a privacy-safe, shareable verdict card.
7. **Keep playing** — Next Case, New Round (rotates roles), or end the game.

A full case takes about five minutes.

## Principles

- **Local-only** gameplay — no backend, login, cloud sync, or network requirement.
- **Privacy by design** — verdict cards never include who voted which way; history stays on device.
- **No ads, no subscriptions** — free to play; extra themed decks are one-time in-app purchases.
- Apple frameworks only: **Swift, SwiftUI, SwiftData**. iOS 17+.

## Architecture

Feature-based MVVM with a small, pure state machine at the core.

- `Sources/Core/Engine` — `GameStore` (the full-case state machine), `VerdictEngine` (pure three-way tally), `JuryRules` (role/voter assignment). UI- and SwiftData-free, so it is fully unit-testable.
- `Sources/Core/Models` — SwiftData `@Model` entities (`CaseDeck`, `GameCase`, `GameSession`, `Player`) and the `Verdict` enum.
- `Sources/Core/DesignSystem` — the "playful courtroom" design language: colors, typography, components, gavel mark, countdown ring, verdict stamp, confetti.
- `Sources/Core/Services` / `Analytics` / `Monetization` — deck seeding, privacy-safe sharing, local analytics, StoreKit-ready unlocks.
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

v1 is feature-complete and ~80–90% production-ready. The remaining production
wiring is the live StoreKit 2 transaction flow (the `StoreService` surface is in
place and unlocks locally for development/TestFlight) and App Store assets
(screenshots, hosted privacy-policy URL). See `Docs/ProjectManagement/Status_Report.md`.

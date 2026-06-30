# Changelog

## 1.0.0 - 2026-06-30 — Full v1 build

Closes the canonical build-to scope in `LAUNCH_READINESS.md` (readiness 28% → ~82%).

### Engine
- Added `GameStore`, a UI- and SwiftData-free full-case state machine: setup → case reveal → arguments → voting → verdict, looping to next case / new round from **every** verdict.
- Introduced the `Verdict` enum (`guilty | notGuilty | hungJury`); the tally is a total function with exact ties → hung jury.
- **Multi-case loop + scoring + "crown the winner" finale:** "Next Case" rotates roles so the spotlight moves around the room; the winning litigant scores a point each case; a finale leaderboard crowns the top scorer(s). (`WinnerView`, `GameStore.scores/standings/winners`.)
- Fixed the 3-player jury bug: `JuryRules` guarantees a non-empty voter set for 2–8 players (litigants argue; judge + jury vote; both litigants vote in a 2-player game).
- Party-reality hardening: add a latecomer (joins jury) or drop a player mid-round without ending the game; safe role reassignment when a litigant leaves; restart; votes live in the store so backgrounding mid-vote is safe.
- Replaced silent `try?` session saves with explicit, non-blocking error handling.

### Content
- Tone-reviewed the starter decks (sign-off in `Docs/Content/Deck_Tone_Signoff.md`) and added per-case argument hints, accent colors, and a work-safe flag (Office Chaos Court is the work-safe icebreaker deck). Four free decks, 40 cases.
- **No monetization in v1** (per `LAUNCH_READINESS.md` §3): Date Night Court ships **free**; the paywall was removed and `StoreService` is an inert stub. Deck packs remain a documented *future* model.

### Verdict card & sharing
- Branded, screenshot-perfect, privacy-safe verdict card (wordmark, case, verdict stamp, winner, tagline). It carries **no** vote breakdown or per-voter data, enforced by tests. The verdict screen also shows a running standings strip.

### Design ("Claude design")
- New "playful courtroom" design system: dynamic light/dark color tokens, dual rounded/serif type scale, reusable components, vector gavel mark, countdown ring, rubber-stamp verdict, and a confetti reveal. Redesigned every screen plus a new About screen, the winner finale, and an app icon + accent color asset catalog.

### Store readiness & project
- Added the app icon, `PrivacyInfo.xcprivacy` (no tracking, no data collected), and `ITSAppUsesNonExemptEncryption = NO`.
- History gained per-item delete and a "Clear all" control.
- Regenerated the Xcode project with `SDKROOT = iphoneos` (fixes iOS-destination resolution) and a registered `PocketPartyCourtTests` target.
- **37 unit tests** (engine, jury, verdict, scoring/finale, share-privacy, seeding, history) — all passing on an iOS 26 simulator.
- Fixed the CI workflow's broken `xcodebuild` line continuation.

## 0.1.0
- Added initial iOS project scaffold.
- Added SwiftUI feature screens.
- Added SwiftData model definitions.
- Added starter decks and project documentation.

## 2026-06-28 - Task 2B engineering review fixes
- Preserved JSON starter deck and case IDs as stable SwiftData string identifiers.
- Made starter seeding granular and idempotent by inserting only missing decks/cases by stable ID.
- Propagated starter JSON loading/decoding failures and surfaced them on Home instead of silently loading forever.
- Added History navigation and a completed-session History view.
- Wired local analytics events through game start, deck selection, case draw, timer completion, vote completion, verdict generation, session save, and history viewing.


## 2026-06-28 - Task 2C build/runtime validation
- Documented repository identity, Swift toolchain version, Swift package command applicability, static Swift syntax check results, and Linux `xcodebuild` unavailability.
- Completed manual Swift source review for obvious compile issues; no fixable source changes were required.

## 2026-06-28 - Task 2E macOS/Xcode CI
- Added GitHub Actions CI on `macos-latest` for real `xcodebuild` validation.
- CI now checks the Xcode version, lists project schemes/targets, builds the `PocketPartyCourt` scheme on an iPhone 16 simulator, conditionally runs tests when a test target exists, reports build/test status to the workflow summary, and uploads xcodebuild logs.
- Added a shared `PocketPartyCourt` Xcode scheme so GitHub Actions can resolve the app scheme consistently.


## 2026-06-28 - Task 2F CI destination fix
- Replaced the hard-coded iPhone 16 CI destination with a runner-local simulator selection step so `xcodebuild` does not fail when the selected macOS/Xcode image lacks that exact simulator device.
- Added a reusable simulator selection script and uploaded `simctl` device inventory with CI artifacts for future diagnosis.

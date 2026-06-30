# Changelog

## 1.0.0 - 2026-06-30 — Full v1 build

### Engine (PR0–PR2)
- Added `GameStore`, a UI- and SwiftData-free full-case state machine: setup → case reveal → arguments → voting → verdict, looping to next case / new round from **every** verdict.
- Introduced the `Verdict` enum (`guilty | notGuilty | hungJury`); the tally is now a total function with exact ties → hung jury.
- Fixed the 3-player jury bug: `JuryRules` guarantees a non-empty voter set for 2–8 players (litigants argue; judge + jury vote; both litigants vote in a 2-player game).
- Party-reality hardening: add a latecomer (joins jury) or drop a player mid-round without ending the game; safe role reassignment when a litigant leaves; restart; votes live in the store so backgrounding mid-vote is safe.
- Replaced silent `try?` session saves with explicit, non-blocking error handling.

### Content & monetization (PR3 + deck packs)
- Tone-reviewed the starter decks and added per-case argument hints, accent colors, and a work-safe flag (Office Chaos Court is the work-safe icebreaker deck).
- Added a premium **Date Night Court** deck behind a one-time IAP, with a paywall and a StoreKit-ready `StoreService` (local unlock fallback). No ads, no subscriptions.

### Verdict card & sharing (PR4)
- Redesigned the shareable verdict card as a branded, screenshot-perfect growth asset (wordmark, case, verdict stamp, winner, tagline). It carries **no** vote breakdown or per-voter data, enforced by tests.

### Design ("Claude design")
- New "playful courtroom" design system: dynamic light/dark color tokens, dual rounded/serif type scale, reusable components, vector gavel mark, countdown ring, rubber-stamp verdict, and a confetti reveal. Redesigned every screen plus a new About screen and an app icon + accent color asset catalog.

### Project & CI
- Regenerated the Xcode project with `SDKROOT = iphoneos` (fixes the iOS-destination resolution) and a registered `PocketPartyCourtTests` unit-test target.
- Added 32 unit tests (engine, jury, verdict, share-privacy, seeding, history) — all passing.
- Fixed the CI workflow's broken `xcodebuild` line continuation so build + tests actually run.

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

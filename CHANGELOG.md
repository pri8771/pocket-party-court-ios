# Changelog

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


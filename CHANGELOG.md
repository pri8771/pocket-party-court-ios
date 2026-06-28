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

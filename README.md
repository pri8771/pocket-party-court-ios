# Pocket Party Court

Pocket Party Court is a funny offline iOS party game where friends put silly disputes on trial, vote locally, and generate shareable verdict cards.

**Status: Building (early).** The app plays one case end to end today (deck → players/roles → case →
timer → vote → verdict → share). The full v1 — a restart-safe, multi-case state machine with scoring,
a "crown a winner" finale, and dynamic add/drop players — is the build-to scope and is not yet
implemented. The canonical launch scope, MVP feature status, bug triage, and production-readiness
checklist live in [`LAUNCH_READINESS.md`](LAUNCH_READINESS.md).

## Principles
- Local-only gameplay
- No backend, login, cloud sync, or third-party packages
- Swift, SwiftUI, and SwiftData only
- iOS 17+

## Setup
1. Open `PocketPartyCourt.xcodeproj` in Xcode 15 or newer.
2. Select an iOS 17+ simulator or device.
3. Build and run the `PocketPartyCourt` target.

## Project Structure
- `PocketPartyCourtApp.swift` — app entry point and SwiftData container
- `Sources/Features` — SwiftUI feature modules
- `Sources/Core` — models, services, analytics, monetization stubs, and design system
- `Sources/Resources` — bundled starter deck content
- `Docs` — product and engineering planning documents

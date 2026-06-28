# Bug Tracker

| ID | Title | Severity | Status | Owner | Notes |
| --- | --- | --- | --- | --- | --- |

## Deferred bugs logged from Task 2B review - 2026-06-28
- GameSession save failures ignored via `try? modelContext.save()` in `VerdictView`; defer explicit save error UI and retry handling.
- Duplicate session risk if `didSaveSession` state is retriggered; defer stronger idempotency around session creation.
- 3-player mode has no jury voter because roles become judge, plaintiff, defendant; defer role/voting rules revision.


## Task 2C validation - 2026-06-28
- No new fixable Swift compile bugs were found during Linux-accessible static syntax validation and manual source review.
- Environment limitation: Xcode runtime build and simulator smoke testing remain blocked in this container because `xcodebuild` is not installed.
- Environment limitation: Swift Package build/test commands were skipped because the repo does not contain `Package.swift` and is currently structured as an Xcode project.

## Task 2D validation - 2026-06-28
- Environment blocker: real Xcode build, unit test execution, simulator launch, and playable vertical-slice smoke testing could not be performed because this runner is Linux, not macOS.
- `xcodebuild -version` failed with `command not found`; `xcrun simctl list runtimes` failed with `xcrun: command not found`.
- No build, test, or runtime product bugs were found or fixed because the mandatory Xcode validation gate failed before source edits.
- Deferred: rerun Task 2D on macOS with Xcode installed and an iPhone 16 iOS Simulator runtime available.

## Task 2E CI setup - 2026-06-28
- Fixed CI infrastructure blocker: no GitHub Actions workflow existed for real macOS/Xcode validation. Added `.github/workflows/ci.yml` to run the required `xcodebuild` version, scheme listing, build, conditional test, status reporting, and log upload steps.
- Fixed scheme discoverability blocker: added a shared `PocketPartyCourt` Xcode scheme under `PocketPartyCourt.xcodeproj/xcshareddata/xcschemes` so CI does not depend on developer-local scheme metadata.
- No compile or test code defects could be fixed locally because this runner is Linux and does not provide `xcodebuild`; CI is now configured to expose any remaining Xcode-only build issues on macOS.
- Deferred: add/register a real `PocketPartyCourtTests` Xcode target so CI can execute the existing test files instead of reporting tests as N/A.

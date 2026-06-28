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

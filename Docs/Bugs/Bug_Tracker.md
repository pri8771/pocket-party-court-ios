# Bug Tracker

| ID | Title | Severity | Status | Owner | Notes |
| --- | --- | --- | --- | --- | --- |

## Deferred bugs logged from Task 2B review - 2026-06-28
- GameSession save failures ignored via `try? modelContext.save()` in `VerdictView`; defer explicit save error UI and retry handling.
- Duplicate session risk if `didSaveSession` state is retriggered; defer stronger idempotency around session creation.
- 3-player mode has no jury voter because roles become judge, plaintiff, defendant; defer role/voting rules revision.

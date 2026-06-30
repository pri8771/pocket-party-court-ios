# Technical PRD

## Objective
Ship an offline-first iOS 17+ SwiftUI party game: local case setup, reveal,
timed arguments, voting, a three-way verdict, and a privacy-safe shareable
verdict card — looping to the next case / new round.

## Requirements
- SwiftUI UI architecture with a pure, testable game-state machine.
- SwiftData persistence for decks, cases, completed sessions, and players.
- No third-party dependencies.
- No backend, login, cloud sync, or network requirement.
- Starter content bundled in app resources.

## Screens (implemented)
Home, game setup, case reveal, argument timer, voting, verdict (with branded
share card), deck list, deck detail, paywall, history, and about.

## Engine guarantees
- `Verdict = guilty | notGuilty | hungJury`; the tally is a total function (exact tie → hung jury).
- A non-empty voter set for 2–8 players (litigants argue; judge + jury vote; both vote in a 2-player game).
- Next case / new round reachable from every verdict.
- Add/drop player mid-round and restart without ending the game; votes survive backgrounding.

## Out of scope (v1)
- Live StoreKit 2 transactions (surface is in place; local unlock for dev).
- Any networked or account-based feature.

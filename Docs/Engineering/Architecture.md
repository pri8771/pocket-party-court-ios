# Architecture

Pocket Party Court uses a feature-based MVVM structure with SwiftUI views, a
pure game-state machine, SwiftData `@Model` entities, and small local services.

## Layers

- **Engine (`Sources/Core/Engine`)** — the heart of the app.
  - `GameStore` (`@Observable`) is the full-case state machine. It walks
    `GamePhase` (`setup → caseReveal → arguments → voting → verdict`) and loops
    back to `caseReveal` for the next case / new round. It works on value types
    (`RoundPlayer`, `DeckContent`, `CaseContent`) and has **no** SwiftUI or
    SwiftData dependency, so every transition is unit-testable headless.
  - `VerdictEngine` — pure three-way tally (`guilty | notGuilty | hungJury`),
    a total function where exact ties resolve to a hung jury.
  - `JuryRules` — role assignment and voter selection. Guarantees a non-empty
    voter set for any supported player count (fixes the old 3-player bug).
- **Core Models (`Sources/Core/Models`)** — SwiftData persistence entities
  (`CaseDeck`, `GameCase`, `GameSession`, `Player`) and the `Verdict` enum.
  Completed cases are snapshotted into `GameSession` for History — privacy-safe
  (vote totals only, never per-voter).
- **Core Services** — `DeckService` (idempotent seeding from `StarterDecks.json`),
  `ShareService` (privacy-safe verdict text), `AnalyticsService` (local, debug
  only), `StoreService` (StoreKit-ready deck-pack unlocks).
- **Design System (`Sources/Core/DesignSystem`)** — colors, typography,
  components, the gavel mark, countdown ring, verdict stamp, and confetti.
- **Features (`Sources/Features`)** — Home, Game (a `GameContainerView` that
  renders the screen for the current phase), Decks + paywall, History, About.

## Game flow

`GameSetupView` builds a `GameStore` and presents `GameContainerView` as a
full-screen cover. The container renders exactly one screen per phase, so the
"what next" action is always unambiguous. Roles, votes, and current case all
live in the store, which keeps the round intact across backgrounding and player
add/drop.

## Testing

`Tests/PocketPartyCourtTests` exercises the engine (transitions, all three
verdict loops, party hardening), jury rules, the verdict tally, share-card
privacy, deck seeding, and history queries. CI runs these on every push/PR.

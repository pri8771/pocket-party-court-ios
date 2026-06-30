# Pocket Party Court — Project Documentation

_Updated 2026-06-30 to match the shipped product and launch scope. See LAUNCH_READINESS.md._

GitHub is the source of truth for this project documentation. Notion indexes this file in the
Priyansh App Factory Command Center. For the authoritative, gated launch scope — MVP feature list
with Built/Partial/Not-built status, bug triage, and the production-readiness checklist — see
[`../LAUNCH_READINESS.md`](../LAUNCH_READINESS.md).

## 00. Executive Summary
Pocket Party Court is an offline iOS party game that turns small, low-stakes disputes into a funny
courtroom bit. A co-located group of 2–6 plays on one phone: they name players, get assigned
courtroom roles, reveal a silly case, run an argument timer, vote locally, and reveal a shareable
verdict card. It is for friend groups, roommates, couples, and party hosts.

**Implementation status (2026-06-30): v1 full build, ~82% production-ready.** The full game is now
implemented: a restart-safe `GameStore` state machine, multi-case loop with per-case scoring and a
"crown the winner" finale, dynamic add/drop of players, the three-way verdict, and a branded,
privacy-safe verdict card. Built/run/tested on an iOS 26 simulator (37 unit tests). Per the launch
scope, **v1 ships with no monetization** (four free decks; `StoreService` inert). See
`../LAUNCH_READINESS.md` for full status.

## 01. Product
**Shipped v1 core loop:** pick a deck → enter 2–8 player names + auto-assigned roles → reveal a case →
argument timer → local Guilty/Not-Guilty voting → verdict → shareable verdict card → next case /
crown the winner. Bundled content: 4 starter decks, 40 cases (`Sources/Resources/StarterDecks.json`).

**Built v1 game system:** a restart-safe state machine that loops across multiple cases, accumulates
per-case score, crowns a winner, and supports adding/dropping players mid-game (`LAUNCH_READINESS.md`
§2 F8/F9 — now Built; §7 B1–B3 — now resolved).

**Out of scope for v1:** custom/user-authored cases, penalty/dare cards, in-app purchases/paid decks,
any backend/online/multiplayer, ads/tracking. (Penalty cards and evidence prompts were in earlier
drafts and are deferred.)

**Acceptance criterion:** a cold group of 4–6 finishes a case in 3–7 minutes without asking "what do
we do now?"

## 02. Design
Playful courtroom theme: bold paper-style cards, dramatic verdict moment, large rounded typography,
one-hand pass-the-phone controls. Implemented screens (`Sources/Features`): Home, Game Setup, Case
Reveal, Timer, Voting, Verdict (with rendered share card), Deck List, Deck Detail, History. A shared
design system lives in `Sources/Core/DesignSystem` (`PPCColors`, `PPCTypography`, `PPCComponents`).
Not yet done: app icon/launch assets, dark-mode audit, verdict-moment haptics/sound, accessibility pass.

## 03. Frontend Technical
SwiftUI card-driven app. State today is implemented as a `NavigationStack` push chain across the game
screens (not a central engine); the intended design is an observable `GameEngine`/`GameSession` state
machine that owns phase, players, current case, votes, round, and scores. Local JSON prompt decks are
bundled and seeded into SwiftData idempotently on first launch (`DeckService`). SwiftData persists
decks, cases, sessions, and players. No required permissions for v1; fully offline.

## 04. Backend Technical
No backend for v1 (hard guardrail). No network calls, accounts, or cloud sync. Future services
(downloadable decks, remote party mode, shared verdict pages) are explicitly out of scope for v1.

## 05. Business
Free core app with the three bundled decks. A future paid "extra deck bundle" is planned only:
`StoreService` declares product id `pocket_party_court.extra_deck_bundle` but is an inert stub with no
StoreKit integration. **No monetization ships in v1.** Guardrails: no ads, no accounts, no tracking,
core gameplay free and offline (`Docs/PRDs/Monetization_Plan_PRD.md`).

## 06. Marketing
Positioning: settle dumb arguments like a court case. Channels: short skits, verdict reveals,
roommate/couple scenarios, group-game communities. The verdict card is the natural shareable artifact.

## 07. User Acquisition
Beta with live friend groups and roommates. Beta success signals (local/DEBUG-only analytics funnel;
nothing transmitted): cases started, cases completed (completion rate), average players, share rate,
repeat sessions. Note: "cases per session / repeat play" is **not measurable in-product yet** because
the multi-case loop is unbuilt.

## 08. Execution
Plan: get the app building/running on real Xcode and wire the test target into CI; fix the 3-player
voting bug; build the restart-safe state machine, multi-case loop, scoring, and winner screen; add
app icon + privacy manifest; reconcile privacy/terms docs and content-tone sign-off; then run a live
cold-group QA. The ordered checklist is in `LAUNCH_READINESS.md` §8.

## 09. QA
Test: empty/long/duplicate names, role assignment **for every player count 2–6** (3-player voting is
currently broken), restart/back mid-case, verdict math (Guilty/Not-Guilty/Hung-Jury), share card
content (must omit private arguments and who-voted-what), offline mode, History persistence, and
accessibility labels. The existing unit tests (`Tests/PocketPartyCourtTests`) cover deck seeding and
history/analytics but **are not yet registered in the Xcode project**, so CI does not run them.

## 10. Legal / Compliance
v1 stays fully local. Run a content-safety review of the starter decks (funny-not-cruel, no targeting
of real individuals, no NSFW/age-inappropriate or politically charged prompts) and record the sign-off
before submission. Privacy docs (`PRIVACY.md`, `PRIVACY_POLICY.md`) must be reconciled and accurate:
the app does persist game history and player names **on device** and records DEBUG-only analytics that
are never transmitted — "No Data Collected" is defensible only because nothing leaves the device. Add
a `PrivacyInfo.xcprivacy` manifest before submission.

## 11. Operations
Release process: real macOS/Xcode build + simulator smoke test → internal live test → small group beta
→ TestFlight → launch. Post-launch: expansion decks (StoreKit), custom rules/cases, and possibly remote
mode — all out of scope for v1.

# Pocket Party Court — Launch Readiness (v1)

> **UPDATE 2026-06-30 (v1 full build):** The build-to gaps in this document are now **closed**.
> The app builds, runs, and passes 37 unit tests on an iOS 26 simulator (Xcode 16). Delivered:
> a restart-safe `GameStore` state machine; the three-way verdict; **multi-case loop with per-case
> scoring and a "crown the winner" finale (F8/F9)**; dynamic add/drop players; the 3-player voting
> fix (B1); a registered, CI-run test target (B4); app icon + `PrivacyInfo.xcprivacy` +
> `ITSAppUsesNonExemptEncryption=NO` (B5); a fixed CI workflow (B6); and a full "playful courtroom"
> design system. Per §3, **v1 ships with no monetization** — all four bundled decks are free and
> `StoreService` is an inert stub. **Re-estimated readiness: ~82%** (was 28%). Section text below is
> the original gap analysis, retained for history; resolved items are marked in this banner and §8.



> **Pocket Party Court** is an offline iOS party game where a co-located group puts silly,
> low-stakes disputes on trial, votes locally on one shared phone, and ends each case with a
> dramatic, shareable verdict card. It is for friend groups, roommates, couples, and party hosts
> who want a 3–7 minute, pass-the-phone bit that needs no accounts, no internet, and no setup.
> The core loop today is: pick a deck → name players & assign courtroom roles → reveal a case →
> run an argument timer → cast local juror votes → reveal the verdict → share the card.
>
> **Implementation maturity: Building (early).** This is a real, structured SwiftUI + SwiftData
> Xcode app (26 Swift files, ~900 LOC) with a screen-by-screen flow that plays one case end to end,
> bundled starter content (`Sources/Resources/StarterDecks.json`), a design system, local analytics,
> and unit-test *files*. It is **not yet** the restart-safe, multi-case game-state machine the product
> plan and the product conversation prioritized as the critical path: there is no multi-round loop,
> no scoring, no dynamic add/drop of players mid-game, and a real 3-player voting bug. Tests exist on
> disk but are **not wired into the Xcode project**, so CI does not actually run them. Several
> store-submission prerequisites (app icon, privacy manifest) are missing. This document is the
> authoritative build-to spec for closing those gaps.

---

## 1. PRD / Launch Scope

**Problem & insight.** Friend groups constantly have tiny, funny disputes ("you ate the last
slice", "you played one song on repeat") that are too trivial to actually argue but genuinely fun
to *adjudicate* as a group. There is no lightweight, offline, pass-the-phone way to turn one of
those into a 5-minute bit with a satisfying, shareable payoff. Existing party apps lean on prompts
but rarely give the moment a verdict and an artifact.

**Target user.**
- **Primary:** in-person friend groups / roommates of 2–6 at a hangout, party, or dinner, with one
  phone passed around. They want zero setup and an instantly understandable loop.
- **Secondary:** couples and families wanting a light, recurring bit; party hosts looking for an
  icebreaker; social-media-leaning users who will screenshot/share the verdict card.

**Value proposition (one sentence).** Turn a dumb argument into a dramatic mock trial and a
shareable verdict in five minutes, entirely offline on one phone.

**Positioning / category & pitch.** Category: offline party / social party game (Games → Family /
Party). One-sentence pitch: *"Put your friends on trial, vote on the verdict, and crown the winner —
no internet, no accounts, just one phone and a gavel."*

**Platform & tech baseline (as actually used in the repo).**
- iOS 17+ (`IPHONEOS_DEPLOYMENT_TARGET = 17.0`), iPhone + iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- Swift 5, SwiftUI for all views, SwiftData (`@Model`) for persistence, `ImageRenderer` for the
  share card, `ShareLink` for share-sheet export, `Timer.publish` for the argument timer.
- **No** third-party packages, **no** `Package.swift` (Xcode-project layout only), **no** backend,
  login, or network calls. Bundle id `com.pocketpartycourt.app`, marketing version `1.0`.

**Business model (only what the repo supports/plans).** Free core app with the three bundled starter
decks. A future paid "extra deck bundle" is *planned only*: `StoreService` declares a product id
`pocket_party_court.extra_deck_bundle` but is a hardcoded stub (`isPremiumUnlocked` always `false`),
with no StoreKit integration and no `.storekit` configuration. Guardrails (per `Docs/PRDs/Monetization_Plan_PRD.md`):
no ads, no accounts, no tracking, core gameplay free and offline. **v1 ships with no monetization.**

**North-star / success signals (local-only / beta-observable, privacy-respecting).** The app already
defines local, in-memory analytics events (`AnalyticsEvent`) covering the funnel: `game_started` →
`deck_selected` → `case_drawn` → `timer_completed` → `vote_completed` → `verdict_generated` →
`session_saved`. For beta these map to the real success signals:
- **Case completion rate:** % of started games that reach a verdict (cold group finishes a case in
  <7 min without confusion — the conversation's explicit usability bar).
- **Cases per session / repeat play:** does a group run a second case? (Currently *not measurable in
  product* because there is no next-case loop — see §2 F8.)
- **Share rate:** % of verdicts that trigger the share sheet.
- Note: analytics are **DEBUG-only and never leave the device**; no remote metrics exist or are
  planned for v1.

---

## 2. MVP Feature List (with acceptance criteria)

Status legend: **Built** = implemented and wired into the flow; **Partial** = present but
incomplete/buggy/not reachable as intended; **Not built** = absent.

### F1. Starter deck content + bundled seeding — **Built**
Three curated decks (Friend Court, Family Tribunal, Office Chaos Court), 10 cases each (30 total),
shipped in `Sources/Resources/StarterDecks.json` and seeded into SwiftData on first launch via
`DeckService.seedStarterDecksIfNeeded` (called from `HomeView.task`).
- **Given** a fresh install, **when** Home appears, **then** all 3 decks load and each shows its
  icon, title, description, and case count.
- Seeding is **idempotent and granular**: re-running it inserts no duplicate decks/cases (verified by
  `DeckServiceTests.testSeedingIsGranularAndIdempotent`); JSON ids are preserved as stable SwiftData
  ids (`testDecodePreservesJSONIDs`).
- A malformed/missing `StarterDecks.json` surfaces a visible "Deck loading issue" message on Home,
  not a silent infinite spinner (`HomeView` `seedingError` path; `testDecodePropagatesJSONErrors`).
- **Content tone is reviewed and signed off** as funny-not-cruel, no targeting of real individuals,
  no NSFW — see §7 and §9. *(Tone is currently safe by inspection but has no recorded sign-off.)*

### F2. Home / deck selection — **Built**
`HomeView` lists decks and routes into setup, plus "Browse All Cases" and "History".
- **Given** decks loaded, **when** the user taps a deck, **then** they navigate to `GameSetupView`
  for that deck.
- **Then** "Browse All Cases" opens `DeckListView` → `DeckDetailView` (read-only deck/case browser).
- Empty state ("Loading starter decks…") shows only while decks are empty and no error is set.

### F3. Player setup + role assignment — **Partial**
`GameSetupView` collects 2–6 player names, validates them, and assigns courtroom roles by order.
- **Given** the setup form, **then** names are validated: 2–6 required, must be unique
  (case-insensitive), empties trimmed; "Reveal First Case" is disabled until valid and the deck has
  cases.
- **Then** roles are assigned by index: 2 players → plaintiff + defendant (both vote); 3+ →
  judge, plaintiff, defendant, then jury.
- **Gap (blocking, see §7 B1):** the **3-player** case assigns judge/plaintiff/defendant and leaves
  **no jury**, so voting silently falls back to the judge as sole voter. This is a known logged
  defect (`Docs/Bugs/Bug_Tracker.md`) and breaks "the group votes."
- **Gap:** players can only be set **before** the case. There is **no add/drop of players
  mid-game** (a stated critical-path requirement). Acceptance criterion *not met*: "a late arrival
  can be added without restarting the case."

### F4. Case reveal — **Built**
`CaseRevealView` shows the drawn case (category + prompt) and names the plaintiff/defendant.
- **Given** a valid setup, **when** "Reveal First Case" is tapped, **then** a random case from the
  deck is shown with its category, prompt, and the assigned plaintiff/defendant names.
- **Then** "Start Arguments" navigates to the timer.
- **Gap:** case selection is `deck.cases.randomElement()` with **no de-duplication** across cases in
  a session, so the same case can repeat (acceptable for v1 single-case, but blocks a clean
  multi-case loop — see F8).

### F5. Argument timer — **Built (with caveats)**
`TimerView` counts down a configurable 30–180s argument window (default 60s, set in setup).
- **Given** a revealed case, **then** a countdown from the chosen duration runs once per second.
- **Then** reaching 0 **or** tapping "Proceed to Vote" advances to voting.
- **Caveats:** timer does **not** pause/resume on backgrounding and is **not** restart-safe (leaving
  and returning re-creates the view at full duration); uses the deprecated
  `NavigationLink(isActive:)` API (`TimerView.swift:35`) — compiles on iOS 17 with a warning but is
  on a removal path.

### F6. Local jury voting — **Partial**
`VotingView` collects one Guilty / Not Guilty vote per juror via segmented pickers and tallies them.
- **Given** the voting screen, **then** each juror has a Pending/Guilty/Not-Guilty control, a live
  tally is shown, and "Read Verdict" is disabled until **all** jurors have voted.
- **Then** when the last vote is cast, `vote_completed` analytics fires.
- **Gap (blocking, ties to B1):** the juror set is derived as `jury`, else `judge`, else *all
  players*. For 3 players this is a single judge-voter; the "everyone votes" model is not honored.
- **Gap:** votes are **not anonymous on screen** (each juror's choice is visible to the room while
  voting). Acceptable for a shared-phone party game but worth a design decision (see §6).

### F7. Verdict + shareable verdict card — **Built**
`GameService.verdict(...)` computes Guilty / Not Guilty / Hung Jury from the tally;
`VerdictView` renders a `VerdictCardView` to a PNG via `ImageRenderer` and exposes it through
`ShareLink`.
- **Given** all votes cast, **then** the verdict is deterministic: guilty>not → "Guilty" (plaintiff
  wins); not>guilty → "Not Guilty" (defendant wins); tie → "Hung Jury".
- **Then** the share card contains **only** the app name, verdict title, case prompt, aggregate
  tally (Guilty N • Not Guilty M), and a comedic summary — **never** private arguments or
  who-voted-what (matches the content/privacy guardrail).
- **Then** "Share Verdict Card" presents the iOS share sheet with the rendered PNG.
- **Gap:** `verdict_shared` analytics event is defined but **never fired** (the share action isn't
  instrumented). `ShareService.verdictCardText(...)` exists but is **dead code** (the view shares the
  PNG, not this text).

### F8. Multi-case / multi-round loop + scoring ("crown a winner") — **Not built**
The product promise on Home is "vote locally, and crown a winner," and `GameSession` carries
`currentRound`, `totalRounds`, and `Player.score`.
- **Required:** after a verdict, offer "Next Case" / "New Round"; advance round counters; accumulate
  per-player score; after the final round, show a winner/leaderboard.
- **Reality:** the flow **ends at one verdict**. `currentRound`/`totalRounds` are never advanced,
  `Player.score` is never mutated, there is no next-case/winner UI. This is the single biggest gap
  between the shipped flow and the intended game (see §7 B2).

### F9. Restart-safe game-state machine — **Not built (as a machine)**
The conversation's #1 priority was "a complete, restart-safe state machine: setup → case →
arguments/votes → verdict → next case/round, with dynamic add/drop players and restart."
- **Reality:** there is **no central state machine.** State is implemented implicitly as a
  SwiftUI `NavigationStack` push chain across six views, each owning ephemeral `@State`. There is no
  single owner of "current game" that can be restarted, resumed, or mutated (add/drop player) without
  unwinding navigation. `GameService` is a stateless helper (2 pure functions), not an engine.
- **Required:** an observable `GameSession`/`GameEngine` that owns phase, players, current case,
  votes, round, and scores, exposes explicit transitions, and is unit-testable headless.

### F10. Local history of completed cases — **Built, but scope-flagged**
`VerdictView.saveCompletedSession()` persists each finished case as a `GameSession`; `HistoryView`
lists completed sessions (deck, verdict, prompt, date).
- **Given** a verdict is reached, **then** a `GameSession` is saved and appears in History.
- **Scope flag:** the product conversation explicitly said **defer local history for v1.** It is
  shipped *on by default*, with **no delete/clear UI**, persisting player names + case prompts on
  device. This both contradicts the agreed scope and adds privacy surface (see §6, §7 B5).
- **Gap:** save errors are swallowed (`try? modelContext.save()`); duplicate-save guard
  (`didSaveSession`) is per-view-instance only (logged deferred bug).

### F11. Local analytics (funnel instrumentation) — **Built (DEBUG-only)**
`AnalyticsService` records events to an in-memory array and `print`s them **only in DEBUG**; nothing
is transmitted.
- **Given** a DEBUG build, **then** funnel events are recorded in order
  (`HistoryAndAnalyticsTests.testAnalyticsServiceRecordsRequiredEventsInDebug`).
- **In RELEASE**, `track(_:)` is a no-op. **Gap:** `app_opened`, `case_revealed`, `vote_cast`,
  `verdict_shared` are defined but never fired.

### F12. Design system + theming — **Built**
`PPCColors`, `PPCTypography`, `PPCComponents` (`PPCCard`, `PPCPrimaryButton`) give a consistent
courtroom-paper look.
- **Then** all screens use the shared palette/typography; verdict card uses the paper background.
- **Gap:** no light/dark-mode audit; some hardcoded RGB; `PPCPrimaryButton` is defined but the flow
  mostly uses system `.borderedProminent` buttons (partial adoption).

### F13. Monetization (extra deck bundle) — **Not built**
`StoreService` is a stub; no StoreKit, no products configured, no purchase/restore flow. Intentionally
deferred per the monetization PRD.

---

## 3. Out of Scope (v1 non-goals)

These are explicitly **not** in v1, by product decision, conversation guardrail, or platform posture:

1. **Any backend / network / cloud sync / accounts / login.** Hard guardrail; the app must run fully
   offline (`Docs/PRDs/Technical_PRD.md`, `README.md`).
2. **Remote / online multiplayer or shared verdict pages.** Future only; v1 is one-device, in-room.
3. **In-app purchases / paid decks / StoreKit.** Stubbed only; no monetization ships in v1.
4. **Ads, tracking, attribution, third-party SDKs.** Forbidden by the monetization guardrails.
5. **User-authored / custom cases or decks.** v1 ships only the three bundled starter decks.
6. **Penalties / dares system** mentioned in `Docs/PROJECT_DOCUMENTATION.md` ("penalty card") —
   out for v1; verdict is the payoff.
7. **Cruel, NSFW, politically charged, or individually-targeting content.** Hard content guardrail
   from the conversation; starter decks stay funny-not-cruel and age-rating safe.
8. **Personal data on the share card** (private arguments, who-voted-what, player roster). The card
   carries only verdict + case + aggregate tally + comedic summary.
9. **Per-juror vote anonymity / secret balloting.** v1 is open voting on a shared phone (a noted
   design choice, §6).
10. *(Scope conflict to resolve, not a clean non-goal:)* **Local history was intended to be deferred**
    but is currently built. Either keep it with a delete UI or gate it off for v1 — see §7 B5.

---

## 4. User Flows

Screen names below are the actual SwiftUI views in `Sources/Features`.

### 4.1 First run / onboarding (implicit, no dedicated onboarding)
1. Launch app → `PocketPartyCourtApp` builds the SwiftData container and shows **`HomeView`**.
2. `HomeView.task` calls `DeckService.seedStarterDecksIfNeeded` → the 3 starter decks seed into
   SwiftData (idempotent).
3. Home shows the title, subtitle, the deck picker, and "Browse All Cases" / "History" links. There
   is no explicit tutorial; the loop is meant to be self-evident.

### 4.2 Core loop — play one case (the path that works today)
1. **`HomeView`** → tap a deck.
2. **`GameSetupView`** → enter 2–6 player names; roles auto-assign by order; set the argument timer
   (30–180s). Validation must pass.
3. Tap **"Reveal First Case"** → a random case is drawn; fires `deck_selected`, `game_started`,
   `case_drawn`.
4. **`CaseRevealView`** → shows category + prompt + plaintiff/defendant → tap **"Start Arguments"**.
5. **`TimerView`** → countdown runs; players argue; tap **"Proceed to Vote"** or wait for 0.
6. **`VotingView`** → each juror picks Guilty / Not Guilty; "Read Verdict" enables once all have
   voted; fires `vote_completed`.
7. **`VerdictView`** → computes and shows the verdict + winner; saves a `GameSession`; renders the
   verdict-card PNG; fires `verdict_generated`, `session_saved`.
8. **End of flow.** *(There is no "Next Case"/"New Round"/winner step — see F8/§7 B2. To play again,
   the user navigates back to Home and restarts setup.)*

### 4.3 Share a verdict
1. From **`VerdictView`**, wait for "Preparing share card…" to resolve.
2. Tap **"Share Verdict Card"** → iOS share sheet with the rendered PNG (verdict + case + tally +
   summary; no private data). *(No `verdict_shared` event fires — instrumentation gap.)*

### 4.4 Browse content / history
1. From **`HomeView`** → "Browse All Cases" → **`DeckListView`** → **`DeckDetailView`** (read-only
   prompts by deck).
2. From **`HomeView`** → "History" → **`HistoryView`** (completed sessions; empty state when none).
   Fires `history_viewed`.

### 4.5 Settings / privacy
- **None in-app.** There is no Settings screen, no history clear/delete, no content filter toggle,
  and no in-app privacy disclosure. (Privacy posture is documented only in repo Markdown.) This is a
  gap for an app that persists player names + prompts on device (§6, §9).

---

## 5. Acceptance Criteria Summary

| Feature | Status | Launch gate (pass condition) |
|---|---|---|
| F1 Starter decks + seeding | Built | 3 decks/30 cases load; seeding idempotent; load errors visible; **tone signed off** |
| F2 Home / deck selection | Built | All decks listed; tap routes to setup; browse/history reachable |
| F3 Player setup + roles | **Partial** | 2–6 unique names validated; **every config (incl. 3p) yields a valid voting body** (B1) |
| F4 Case reveal | Built | Random case shown with plaintiff/defendant; advances to timer |
| F5 Argument timer | Built | Counts down from chosen duration; advances at 0 or on tap; (restart-safety = §6) |
| F6 Local voting | **Partial** | One vote per juror; verdict gated on all votes; **3p voting fixed** (B1) |
| F7 Verdict + share card | Built | Correct verdict math; card carries **no private data**; share sheet works |
| F8 Multi-case loop + scoring | **Not built** | "Next Case"/"New Round", scoring, and winner exist (B2) |
| F9 Restart-safe state machine | **Not built** | Central engine owns state; restart/resume/add-drop work; headless-tested (B2/B3) |
| F10 Local history | Built (flagged) | Scope decision recorded; if kept, **clear/delete UI exists** (B5) |
| F11 Local analytics | Built (DEBUG) | Funnel events fire in order; no data leaves device |
| F12 Design system | Built | Consistent palette/typography; dark-mode audited |
| F13 Monetization | Not built | N/A for v1 (out of scope) |

**Overall product-level launch gate (from the conversation):** hand the app to a cold group of 4–6
with no explanation; they complete a case in **under 7 minutes** without asking "what do we do now?"
This cannot be fully passed until B1 (3-player voting) and B2 (a restart-safe multi-case loop /
clean "play again") are resolved.

---

## 6. Known Limitations

- **Single-case flow, no replay loop.** The game plays exactly one case then stops; "crown a winner"
  is unimplemented. Replaying means manually navigating back to Home.
- **No central, restart-safe state machine.** Game state lives in per-screen SwiftUI `@State` along a
  navigation chain. Backgrounding, force-quit, or navigating back mid-case is not gracefully resumed;
  the timer resets to full on re-entry.
- **3-player voting is broken** (no jury voter; judge decides alone). Other counts (2, 4–6) behave,
  but 3 is a very common party size.
- **Open (non-secret) voting.** Jurors see each other's picks on the shared phone; there is no secret
  ballot. Fine for a party bit, but it changes the social dynamic and should be a conscious choice.
- **Case repetition possible.** Cases are drawn with `randomElement()` and no per-session exclusion.
- **History is on with no management UI.** Player names and case prompts persist in SwiftData with no
  in-app way to view-delete or clear, and history was meant to be deferred for v1.
- **Analytics gaps.** Several declared events never fire (`app_opened`, `case_revealed`, `vote_cast`,
  `verdict_shared`); analytics are DEBUG-only by design.
- **No app icon / launch assets.** No `Assets.xcassets`/AppIcon despite the build setting referencing
  `AppIcon`; archive/submission will flag this.
- **No privacy manifest / explicit Info.plist.** `PrivacyInfo.xcprivacy` and a managed `Info.plist`
  are absent; `ITSAppUsesNonExemptEncryption` is undeclared.
- **Tests not wired to the project.** The two test files are not in `project.pbxproj` and the scheme's
  `<Testables>` is empty, so `xcodebuild test` runs nothing.
- **Device/runtime caveats.** All build/test validation to date was static (the dev container was
  Linux without Xcode); the app has **not been confirmed to compile, run, or pass tests on a real
  macOS/Xcode/simulator**. This is the largest unknown.

---

## 7. Bug & Risk Triage

### Launch-blocking (must fix before TestFlight / App Store)

- **B1 — 3-player mode has no jury; judge decides alone.**
  Where: `Sources/Features/Game/GameSetupView.swift` (role assignment) +
  `Sources/Features/Game/VotingView.swift` (`jurors` fallback to judge). Also logged in
  `Docs/Bugs/Bug_Tracker.md`.
  Why blocking: 3 is a core party size; "everyone votes" silently collapses to one voter, breaking
  the central mechanic and the verdict's legitimacy. Fix the role/voting rules so every supported
  player count yields a real voting body (e.g. judge always votes, or jury includes all non-litigants,
  or 3p makes both non-defendant players jurors).

- **B2 — No multi-case loop, no scoring, no "crown a winner."**
  Where: missing across `VerdictView` (no next-case path), `GameSession.currentRound/totalRounds`
  (never advanced), `Player.score` (never mutated). Feature F8/F9.
  Why blocking: the app's own promise ("vote locally, and crown a winner") and the conversation's
  critical path are unmet; a party game that plays one case and stops will not retain a room. Needs a
  restart-safe loop with "Next Case"/"New Round" and a winner screen.

- **B3 — No restart-safe game-state machine; state is navigation-bound.**
  Where: flow is a `NavigationStack` push chain (`HomeView`→…→`VerdictView`); `GameService` is
  stateless. Feature F9.
  Why blocking: the prioritized requirement was an engine that survives restart and supports dynamic
  add/drop players. Without it, B2 and dynamic players cannot be implemented cleanly, and mid-case
  interruptions lose state. Introduce an observable `GameEngine` owning phase/players/case/votes/round/score.

- **B4 — Tests are not registered in the Xcode project; CI runs zero tests.**
  Where: `PocketPartyCourt.xcodeproj/project.pbxproj` defines only the app target; the shared scheme's
  `<Testables>` is empty; `.github/workflows/ci.yml` "Detect test target" therefore returns false and
  reports tests **N/A**.
  Why blocking: the engine logic (verdict math, seeding, future state machine) ships **unverified by
  CI**. Add a `PocketPartyCourtTests` unit-test target, add it to the scheme's `<Testables>`, and make
  CI fail on test failure.

- **B5 — Missing App Store submission prerequisites: app icon + privacy manifest.**
  Where: no `Assets.xcassets`/AppIcon (build setting references `AppIcon` that doesn't exist); no
  `PrivacyInfo.xcprivacy`; no managed `Info.plist`; `ITSAppUsesNonExemptEncryption` undeclared.
  Why blocking: App Store Connect rejects builds without an app icon and (as of 2024) requires a
  privacy manifest. Encryption-exemption declaration is needed to avoid export-compliance prompts.

- **B6 — CI build/test invocation (RESOLVED 2026-06-30).** The earlier `ci.yml` had mangled
  `build`/`test` line-continuations. The workflow was rewritten this pass to select a simulator via
  `.github/scripts/select-ios-simulator.sh` and pass a well-formed `-destination`; an independent
  audit confirmed the build/test actions are now syntactically correct. No longer a launch blocker —
  it just still needs a green run on a macOS runner to prove the app actually compiles (see B8).

- **B7 — Privacy policy doc is self-contradictory and corrupted; reconcile before store privacy
  labeling.**
  Where: `PRIVACY_POLICY.md` (mangled nested-list markdown from line ~19 on) claims "collects no data
  / no analytics," while the app ships a local `AnalyticsService` and persists `GameSession` history
  on device; `PRIVACY.md` is the cleaner statement.
  Why blocking (compliance, not code): the App Store privacy questionnaire and the published policy
  must accurately and consistently describe on-device persistence + DEBUG-only analytics ("No Data
  Collected" is defensible since nothing leaves the device, but the doc must be fixed and consistent).

- **B8 — No verified macOS/Xcode build or runtime smoke test.**
  Where: `Docs/ProjectManagement/Status_Report.md` / `Bug_Tracker.md` — every prior validation was
  static on Linux; `xcodebuild`/simulator never ran successfully.
  Why blocking: there is no evidence the app compiles, launches, plays a case, or that SwiftData
  seeding works on device. Must build, run, and smoke-test one full case on a real simulator before
  TestFlight.

### Non-blocking (ship-with / fix later)

- **N1 — Deprecated `NavigationLink(isActive:)`** in `TimerView.swift:35`. Compiles on iOS 17 with a
  warning; migrate to `navigationDestination`/path-based navigation when the engine lands.
- **N2 — Swallowed save errors** (`try? modelContext.save()` in `VerdictView.saveCompletedSession`)
  and weak duplicate-save guard (`didSaveSession` is per-view-instance). Add explicit error handling
  with the engine.
- **N3 — Dead / unused code:** `ShareService.verdictCardText(...)` is never called;
  `HomeViewModel.headline`/`playerNames` are unused.
- **N4 — Unfired analytics events:** `app_opened`, `case_revealed`, `vote_cast`, `verdict_shared`
  defined but never tracked. Wire them or remove.
- **N5 — Case repetition within a play session** (`randomElement()` with no exclusion). Matters once
  the multi-case loop (B2) exists; add per-session de-dup then.
- **N6 — Open voting (no secret ballot).** Acceptable for v1; revisit if play-testing shows social
  friction.
- **N7 — Design polish:** no dark-mode audit; `PPCPrimaryButton` underused; hardcoded RGB colors;
  no haptics/sound on the verdict moment (which is the emotional payoff).
- **N8 — No accessibility pass** (VoiceOver labels, Dynamic Type at large sizes, segmented-picker
  labels). Required eventually; not a hard launch blocker for a v1 party game but should be on the
  list.

---

## 8. Production-Readiness Assessment

**Current estimated readiness: ~82%.**  _(Recalibrated upward from 28% on 2026-06-30 after the v1 full build: the app now builds/runs/tests on real Xcode, the multi-case loop + scoring + winner finale + restart-safe engine landed, the 3-player bug is fixed, the test target runs in CI, and the app icon + privacy manifest were added. Original 28% justification retained below for history.)_

Justification: the app is a real, coherent SwiftUI + SwiftData project with a clean architecture, a
design system, well-formed bundled content, idempotent seeding, and a flow that plays **one** case
end to end — a genuine vertical slice. But it is materially short of the agreed v1: the **core game
loop is single-shot** (no multi-case/scoring/winner — B2), there is **no restart-safe state machine**
(B3), a **real correctness bug at 3 players** (B1), **tests don't run in CI** (B4), and **store/privacy
prerequisites are missing** (B5/B7). Critically, the app has
**never been verified to build or run on real Xcode** (B8). That combination caps confidence well
below the "MVP Ready" bar (core loop runs end-to-end with tests; only polish/content/store left).

### Ordered checklist to reach 80–90% production-ready
1. **Get it building & running for real (B8, B6).** Fix `ci.yml` line-continuations; build and launch
   on an iOS 17 simulator; smoke-test one full case (seed → setup → reveal → timer → vote → verdict →
   share). Capture a passing CI run.
2. **Wire the test target (B4).** Add `PocketPartyCourtTests` to `project.pbxproj`, add it to the
   scheme `<Testables>`, ensure existing tests run and CI **fails** on red.
3. **Fix 3-player voting (B1).** Revise role/jury rules so every 2–6 count produces a valid voting
   body; add unit tests for each count (2,3,4,5,6) asserting voter set and verdict.
4. **Introduce a restart-safe `GameEngine` (B3).** An observable model owning phase, players, current
   case, votes, round, scores; explicit transitions; fully headless unit-tested. Re-point the views at
   it.
5. **Build the multi-case loop + scoring + winner (B2).** "Next Case"/"New Round"; advance
   round counters; accumulate `Player.score`; final winner/leaderboard screen; per-session case
   de-dup (N5).
6. **Add dynamic add/drop players mid-game** on top of the engine (re-balance roles/jurors safely).
7. **Add app icon + `Assets.xcassets`, `PrivacyInfo.xcprivacy`, and `ITSAppUsesNonExemptEncryption`
   (B5).** Verify archive succeeds.
8. **Reconcile privacy docs + in-app privacy/history controls (B7, B5).** Fix `PRIVACY_POLICY.md`;
   make the App Store privacy answers consistent; add a Settings screen with "Clear History" (and a
   decision on whether history ships at all).
9. **Record the content-tone sign-off (F1, §9).** Run the deck rubric (funny-not-cruel, no targeting,
   age-safe, stays funny on the 3rd play), document the pass, and set the age rating accordingly.
10. **Instrument the funnel fully (N4)** and add the verdict-moment polish (haptics/sound) (N7).
11. **Accessibility + dark-mode pass (N8, N7).**
12. **Run the cold-group play test** (4–6 people, no instructions, <7 min to a verdict) and fix what
    confuses them.

Completing 1–7 lands roughly 80% (a real, tested, store-eligible game loop); 8–12 push toward 90% and
a credible TestFlight.

**v1 full-build status (2026-06-30):** Items **1–7 are complete** and **8–11 are largely done**
(per-item notes below). Item **12 (cold-group play test)** is the open human gate.
1 ✅ builds/runs/smoke-tested on iOS 26 · 2 ✅ test target in CI (37 tests) · 3 ✅ 3-player voting fixed ·
4 ✅ `GameStore` restart-safe engine · 5 ✅ multi-case loop + scoring + "crown the winner" finale ·
6 ✅ add/drop players mid-game · 7 ✅ app icon + `PrivacyInfo.xcprivacy` + `ITSAppUsesNonExemptEncryption=NO` ·
8 ◧ history clear/delete + privacy in About done; App Store questionnaire + hosted URL remain ·
9 ✅ tone sign-off in `Docs/Content/Deck_Tone_Signoff.md` · 10 ✅ funnel cleaned + verdict haptics (sound deferred) ·
11 ◧ dynamic light/dark + Dynamic Type + VoiceOver labels; formal a11y audit remains · 12 ⏳ human play test.
**Monetization stays off for v1** (§3.3): all four decks free, `StoreService` inert. Re-estimated readiness **~82%**.

### Test coverage summary
- **What's tested (files present):**
  - `DeckServiceTests`: JSON id preservation, JSON error propagation, idempotent/granular seeding.
  - `HistoryAndAnalyticsTests`: completed-session History query, DEBUG analytics event ordering.
- **Critically: these tests do not run** — no test target in the Xcode project / scheme, so CI reports
  tests **N/A** (B4). Coverage is effectively **0% enforced**.
- **What's not tested at all:** verdict math (`GameService.verdict` — easy, high-value to add),
  role/jury assignment (the source of B1), the (missing) state machine and multi-case loop, share-card
  rendering, and any UI flow. No UI/integration tests exist.

---

## 9. Launch Checklist

**Build & CI**
- [ ] App builds and runs on an iOS 17 simulator and a real device (B8).
- [ ] `ci.yml` build/test invocations fixed and green (B6); CI fails on test failure.
- [ ] `PocketPartyCourtTests` target registered and run by CI (B4).

**Functionality gates**
- [ ] 3-player (and 2,4,5,6) voting produces a valid jury and correct verdict (B1).
- [ ] Multi-case loop, scoring, and winner screen work; "play again" is one tap (B2).
- [ ] State survives backgrounding / re-entry; add/drop player works (B3).
- [ ] Full cold-group play test passes (<7 min, no "what now?").

**App Store / project config**
- [ ] App icon + `Assets.xcassets` added; archive succeeds (B5).
- [ ] `Info.plist` managed; `ITSAppUsesNonExemptEncryption = false` declared (no encryption used).
- [ ] Bundle id, version, and build number finalized; screenshots for iPhone (and iPad if shipping).

**Privacy & data**
- [ ] `PrivacyInfo.xcprivacy` added (declare: no tracking; SwiftData local storage; no required-reason
      APIs beyond defaults) (B5).
- [ ] `PRIVACY_POLICY.md` fixed and reconciled with `PRIVACY.md`; App Store privacy questionnaire
      answered consistently (on-device persistence; DEBUG-only, non-transmitted analytics) (B7).
- [ ] In-app "Clear History"/data-management control added **or** a documented decision to not ship
      history in v1 (B5/F10).
- [ ] Support contact filled in (placeholder `[Add support email or URL]` in `PRIVACY_POLICY.md`).

**Content & safety**
- [ ] Starter-deck tone sign-off recorded: funny-not-cruel, **no targeting of real individuals**, no
      NSFW/age-inappropriate content, no politically charged or legally sensitive prompts; each prompt
      "stays funny on the 3rd play" (conversation guardrail).
- [ ] Age rating set to match the reviewed tone (target a broad, mild rating; confirm no content forces
      17+).
- [ ] Verdict card confirmed to expose **only** verdict + case + aggregate tally + summary — never
      private arguments, who-voted-what, or the player roster.
- [ ] `TERMS_OF_SERVICE.md` "designed for adults and mature teenagers" reconciled with the chosen age
      rating and the "all ages" claim in `PRIVACY_POLICY.md` (these currently disagree).

**Store listing**
- [ ] Category (Games → Family/Party), description, keywords, and a verdict-card-led screenshot set.
- [ ] Monetization confirmed off for v1 (StoreService stub remains inert; no IAP submitted).

---

_Authored 2026-06-30 as the canonical launch-scope artifact for Pocket Party Court. All statements are
grounded in the repository at the current `main`. Status: **Building (early)** — see §8 for the path
to MVP Ready._

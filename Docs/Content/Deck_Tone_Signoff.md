# Starter Deck — Content Tone Sign-off

**Date:** 2026-06-30 · **Scope:** all bundled decks in `Sources/Resources/StarterDecks.json`
(Friend Court, Family Tribunal, Office Chaos Court, Date Night Court — 40 cases total).

## Rubric (per the conversation guardrail)
Every prompt was reviewed against four tests:
1. **Funny, not cruel** — pokes at a *behavior*, never a person's identity, appearance, or worth.
2. **No targeting of real individuals** — prompts are about generic, universal small annoyances.
3. **Age-safe / not NSFW** — no sexual content, no slurs, no substances, nothing politically charged
   or legally sensitive. Suitable for a broad rating.
4. **Stays funny on the 3rd play** — the humor is situational, so re-draws still land.

## Result: PASS
- All 40 prompts target relatable *behaviors* ("ate the last slice", "replied-all with 'thanks'",
  "stole the blanket"), not people. None reference protected characteristics or real persons.
- **Office Chaos Court** is additionally certified **work-safe** (no innuendo, safe for a team
  icebreaker); flagged `isWorkSafe: true`.
- **Date Night Court** is playful-couple themed (mild, PG); flagged `isWorkSafe: false` so hosts can
  choose context. Nothing in it is adult-only.
- No prompt invites cruelty toward a specific person in the room; the verdict card likewise carries
  no per-voter data (see `ShareServicePrivacyTests`).

## Age rating
Target a broad, mild rating (e.g. 4+ / 9+ for "Infrequent/Mild Mature/Suggestive Themes" at most).
No content forces a 17+ rating. Reconcile `TERMS_OF_SERVICE.md` wording with this before submission.

## Ongoing
Re-run this rubric for any new deck before it ships. Live tone is also checked in the cold play test
(criterion 4 in `Docs/Business/Beta_Playtest_Plan.md`): zero prompts may land as cruel toward a real
person in the room.

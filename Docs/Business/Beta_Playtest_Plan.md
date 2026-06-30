# Beta Play-test Plan

The consumer loop is the validator. This is the gate that decides whether the
revenue lane (B2B Verdict Room) ever opens. Defined **before** running so a
friendly room can't rubber-stamp it.

## Setup
- Recruit 8–10 host-type people (the person who owns game night), ideally from
  one or two Discord/Reddit party-game communities — not friends of the dev.
- Run 2–3 sessions of 4–6 people each.
- Hand them the app cold. **Zero coaching.** Observe, don't help.
- Include the work-safe deck (Office Chaos Court) in at least one session to get
  early tone signal for the future B2B deck.

## Pass/fail criteria (the gate)
A session passes only if all four hold:

1. **Time-to-first-verdict under 5 minutes** from cold open (setup friction is the #1 killer).
2. **The group plays ≥3 cases** without us prompting them to continue (the loop pulls, not politeness).
3. **At least one verdict card is screenshotted or shared** organically in the session (the artifact is the ad).
4. **Zero prompts land as cruel-toward-a-real-person** in the room (live PR3 tone check).

Miss two of four → fix the consumer loop before any B2B work begins.

## What to watch
- Where does the room hesitate ("what do we do now?")? Every such moment is a
  next-action clarity bug.
- Which prompts get the biggest laugh vs. fall flat vs. feel mean. Cut the mean
  ones; promote the bangers.
- Whether anyone reopens the app unprompted later (host retention signal).

## Instrumentation
Local analytics already track the loop (`game_started`, `case_drawn`,
`vote_completed`, `verdict_generated`, `verdict_shared`, `next_case_started`).
For a beta build, surface these to a lightweight local log to measure
time-to-first-verdict and cases-per-session without sending anything off device.

# Monetization Plan PRD

## Strategy
Free local party game with optional one-time deck-pack purchases. Party games
are a poor fit for subscriptions and ads; the free decks are the marketing and
the shareable verdict card is the acquisition engine. Loyal hosts buy a pack or
two that map to occasions they already plan around.

## Implemented (v1)
- Free, fully playable game with three decks (Friend Court, Family Tribunal, Office Chaos Court).
- One premium deck (**Date Night Court**) behind a one-time in-app purchase, surfaced via a clean paywall.
- `StoreService` exposes the unlock surface the UI needs and persists entitlements locally. Real StoreKit 2 (`Product.purchase()` / `Transaction.currentEntitlements`) is the remaining wiring and slots into the same call sites; it requires App Store Connect product configuration.

## Guardrails
- No ads.
- No subscriptions.
- No account system; everything stays on device.
- No tracking-based personalization.
- Core gameplay remains offline and fully playable without any purchase.

## Pricing
- Deck packs: one-time $1.99–$3.99 (default display $2.99 until live pricing loads).

## Future revenue lane (not built in the iOS app)
A work-safe, web/meeting-friendly "Verdict Room" for small remote-heavy teams is
the more durable revenue thesis. It reuses the same engine but ships on its own
channel. See `Docs/Business/B2B_Verdict_Room.md`. Build only after the consumer
loop passes the cold play-test gate.

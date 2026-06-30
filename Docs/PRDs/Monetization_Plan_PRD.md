# Monetization Plan PRD

## Strategy
Free local party game. **v1 ships with no monetization** — no ads, no
subscriptions, no in-app purchases — per the canonical launch scope
(`LAUNCH_READINESS.md` §3). Party games are a poor fit for subscriptions and
ads; the free decks are the marketing and the shareable verdict card is the
acquisition engine.

## v1 (shipped)
- Fully free with four bundled decks (Friend Court, Family Tribunal, Office Chaos Court, Date Night Court — 40 cases).
- `StoreService` is an **inert stub**: it declares the planned product id and the unlock surface the UI reads, but performs no StoreKit work and reports every deck unlocked.

## Future model (post-traction, not in v1)
One-time deck-pack purchases (no subscriptions, ever). The conversation thread
endorsed deck packs as the consumer model, gated behind traction. When that
ships, the live StoreKit 2 flow (`Product.products(for:)` → `purchase()` →
`Transaction.currentEntitlements`) slots into `StoreService`.

## Guardrails
- No ads.
- No subscriptions.
- No account system; everything stays on device.
- No tracking-based personalization.
- Core gameplay remains offline and fully playable without any purchase.

## Future revenue lane (separate channel)
A work-safe, web/meeting-friendly "Verdict Room" for small remote-heavy teams is
the more durable revenue thesis (`Docs/Business/B2B_Verdict_Room.md`). Build only
after the consumer loop passes the cold play-test gate.

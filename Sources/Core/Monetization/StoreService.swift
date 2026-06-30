import Foundation
import Observation

/// Inert monetization stub.
///
/// Product decision (locked launch scope): **v1 ships with no monetization** —
/// no ads, no subscriptions, no in-app purchases. All four bundled decks are
/// free. A future paid "extra deck bundle" is planned only; this type declares
/// the product id and the unlock surface the UI reads, but performs no StoreKit
/// work. Every deck reports unlocked.
@Observable
final class StoreService {
    static let shared = StoreService()

    /// Planned (not shipped) product identifier for the future deck bundle.
    static let plannedDeckBundleID = "pocket_party_court.extra_deck_bundle"

    init() {}

    /// Always unlocked in v1 — there are no paid decks.
    func isUnlocked(_ deck: CaseDeck) -> Bool { true }
}

import Foundation
import Observation

/// Tracks which premium deck packs are unlocked.
///
/// Product model (locked): the game is free with three decks; extra themed
/// decks are one-time in-app purchases (no subscriptions, no ads). Unlocks are
/// persisted locally so a purchase survives relaunches.
///
/// The real StoreKit 2 transaction flow (`Product.products(for:)` →
/// `product.purchase()` → `Transaction.currentEntitlements`) is the remaining
/// production wiring; it requires App Store Connect product configuration. This
/// service exposes the same surface the UI needs and unlocks locally so the
/// paywall is fully functional in development and TestFlight review.
@Observable
final class StoreService {
    static let shared = StoreService()

    private let defaultsKey = "ppc.unlockedProductIDs"
    private(set) var unlockedProductIDs: Set<String>

    /// Display price shown on the paywall until live StoreKit pricing loads.
    let displayPrice = "$2.99"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored = defaults.array(forKey: defaultsKey) as? [String] ?? []
        self.unlockedProductIDs = Set(stored)
    }

    private let defaults: UserDefaults

    func isUnlocked(_ deck: CaseDeck) -> Bool {
        guard deck.isPremium, !deck.productID.isEmpty else { return true }
        return unlockedProductIDs.contains(deck.productID)
    }

    func isUnlocked(productID: String) -> Bool {
        productID.isEmpty || unlockedProductIDs.contains(productID)
    }

    /// Completes a purchase. Today this records a local entitlement; swapping in
    /// `product.purchase()` keeps this exact call site.
    @MainActor
    func purchase(productID: String) async -> Bool {
        guard !productID.isEmpty else { return true }
        // Simulate the async StoreKit round-trip.
        try? await Task.sleep(nanoseconds: 350_000_000)
        unlock(productID: productID)
        return true
    }

    @MainActor
    func restorePurchases() async {
        // Real impl: iterate `Transaction.currentEntitlements`. Local stub keeps
        // whatever is already unlocked.
    }

    private func unlock(productID: String) {
        unlockedProductIDs.insert(productID)
        defaults.set(Array(unlockedProductIDs), forKey: defaultsKey)
    }

    #if DEBUG
    func resetForTesting() {
        unlockedProductIDs.removeAll()
        defaults.removeObject(forKey: defaultsKey)
    }
    #endif
}

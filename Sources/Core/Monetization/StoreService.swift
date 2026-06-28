import Foundation

final class StoreService {
    enum Product: String, CaseIterable {
        case extraDeckBundle = "pocket_party_court.extra_deck_bundle"
    }

    var isPremiumUnlocked: Bool { false }
}

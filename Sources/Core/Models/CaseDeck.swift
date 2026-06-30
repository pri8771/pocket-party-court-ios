import SwiftUI
import SwiftData

@Model
final class CaseDeck {
    @Attribute(.unique) var id: String
    var title: String
    var deckDescription: String
    var icon: String
    /// Sort/display order from the bundled catalog.
    var sortIndex: Int
    /// Hex accent used to color the deck card and downstream screens.
    var accentHex: String
    /// True when the deck is reviewed as office/family friendly (no PG-13 risk).
    var isWorkSafe: Bool
    /// True for paid deck packs (one-time IAP). Free decks ship unlocked.
    var isPremium: Bool
    /// StoreKit product identifier for premium packs (empty for free decks).
    var productID: String
    @Relationship(deleteRule: .cascade) var cases: [GameCase]

    init(
        id: String,
        title: String,
        deckDescription: String,
        icon: String = "⚖️",
        sortIndex: Int = 0,
        accentHex: String = "F0782C",
        isWorkSafe: Bool = false,
        isPremium: Bool = false,
        productID: String = "",
        cases: [GameCase] = []
    ) {
        self.id = id
        self.title = title
        self.deckDescription = deckDescription
        self.icon = icon
        self.sortIndex = sortIndex
        self.accentHex = accentHex
        self.isWorkSafe = isWorkSafe
        self.isPremium = isPremium
        self.productID = productID
        self.cases = cases
    }

    var accent: Color { Color(hex: UInt32(accentHex, radix: 16) ?? 0xF0782C) }
}

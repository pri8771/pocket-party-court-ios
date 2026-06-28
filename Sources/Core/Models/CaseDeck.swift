import Foundation
import SwiftData

@Model
final class CaseDeck {
    var id: UUID
    var title: String
    var deckDescription: String
    var icon: String
    @Relationship(deleteRule: .cascade) var cases: [GameCase]

    init(id: UUID = UUID(), title: String, deckDescription: String, icon: String = "⚖️", cases: [GameCase] = []) {
        self.id = id
        self.title = title
        self.deckDescription = deckDescription
        self.icon = icon
        self.cases = cases
    }
}

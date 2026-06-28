import Foundation
import SwiftData

@Model
final class Player {
    var id: UUID
    var name: String
    var emoji: String
    var score: Int

    init(id: UUID = UUID(), name: String, emoji: String = "⚖️", score: Int = 0) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.score = score
    }
}

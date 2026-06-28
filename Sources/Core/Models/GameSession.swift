import Foundation
import SwiftData

@Model
final class GameSession {
    var id: UUID
    var createdAt: Date
    var currentRound: Int
    var totalRounds: Int
    var selectedDeckTitle: String
    @Relationship(deleteRule: .cascade) var players: [Player]

    init(id: UUID = UUID(), createdAt: Date = .now, currentRound: Int = 1, totalRounds: Int = 5, selectedDeckTitle: String, players: [Player] = []) {
        self.id = id
        self.createdAt = createdAt
        self.currentRound = currentRound
        self.totalRounds = totalRounds
        self.selectedDeckTitle = selectedDeckTitle
        self.players = players
    }
}

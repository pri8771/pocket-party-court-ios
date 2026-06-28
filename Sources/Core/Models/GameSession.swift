import Foundation
import SwiftData

@Model
final class GameSession {
    var id: UUID
    var createdAt: Date
    var completedAt: Date?
    var currentRound: Int
    var totalRounds: Int
    var selectedDeckTitle: String
    var casePrompt: String
    var guiltyVotes: Int
    var notGuiltyVotes: Int
    var verdictTitle: String
    var verdictSummary: String
    @Relationship(deleteRule: .cascade) var players: [Player]

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        completedAt: Date? = nil,
        currentRound: Int = 1,
        totalRounds: Int = 1,
        selectedDeckTitle: String,
        casePrompt: String = "",
        guiltyVotes: Int = 0,
        notGuiltyVotes: Int = 0,
        verdictTitle: String = "",
        verdictSummary: String = "",
        players: [Player] = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.currentRound = currentRound
        self.totalRounds = totalRounds
        self.selectedDeckTitle = selectedDeckTitle
        self.casePrompt = casePrompt
        self.guiltyVotes = guiltyVotes
        self.notGuiltyVotes = notGuiltyVotes
        self.verdictTitle = verdictTitle
        self.verdictSummary = verdictSummary
        self.players = players
    }
}

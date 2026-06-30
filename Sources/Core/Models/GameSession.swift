import Foundation
import SwiftData

/// A completed case, persisted for the local History view. Only privacy-safe
/// data is stored: deck, case prompt, outcome, vote totals (not who voted
/// what), and the participating players. Nothing leaves the device.
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
    /// Human-readable verdict title (kept for display + back-compat).
    var verdictTitle: String
    /// Raw `Verdict` value so History can recover the typed outcome + tint.
    var verdictRawValue: String
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
        verdictRawValue: String = "",
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
        self.verdictRawValue = verdictRawValue
        self.verdictSummary = verdictSummary
        self.players = players
    }

    /// Typed outcome, recovered from the raw value (falls back via title).
    var verdict: Verdict? {
        Verdict(rawValue: verdictRawValue)
            ?? Verdict.allCases.first { $0.title == verdictTitle }
    }
}

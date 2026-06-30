import Foundation

/// The phases of a single case. The `GameStore` is a small state machine that
/// walks these in order, with `verdict` able to loop back to `caseReveal` for
/// the next case / new round.
enum GamePhase: String, Codable, CaseIterable, Equatable {
    case setup
    case caseReveal
    case arguments
    case voting
    case verdict
    /// The "crown the winner" leaderboard shown when the group ends the game.
    case finale
}

/// Plain-value snapshot of a deck's content, decoupled from SwiftData so the
/// engine is testable without a model container.
struct DeckContent: Codable, Equatable, Hashable {
    let id: String
    let title: String
    let accentHex: String

    init(id: String, title: String, accentHex: String) {
        self.id = id
        self.title = title
        self.accentHex = accentHex
    }
}

/// Plain-value snapshot of a single case.
struct CaseContent: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let prompt: String
    let category: String
    let plaintiffHint: String
    let defendantHint: String
}

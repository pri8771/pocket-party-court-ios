import Foundation

struct VerdictResult: Equatable {
    let title: String
    let winnerName: String
    let summary: String
    let guiltyVotes: Int
    let notGuiltyVotes: Int
}

final class GameService {
    func createSession(deckTitle: String, casePrompt: String, players: [Player]) -> GameSession {
        GameSession(selectedDeckTitle: deckTitle, casePrompt: casePrompt, players: players)
    }

    func verdict(guiltyVotes: Int, notGuiltyVotes: Int, plaintiffName: String, defendantName: String) -> VerdictResult {
        if guiltyVotes == notGuiltyVotes {
            return VerdictResult(
                title: "Hung Jury",
                winnerName: "The Drama",
                summary: "The jury is split, the gavel is tired, and everyone is sentenced to snacks before a rematch.",
                guiltyVotes: guiltyVotes,
                notGuiltyVotes: notGuiltyVotes
            )
        }

        if guiltyVotes > notGuiltyVotes {
            return VerdictResult(
                title: "Guilty",
                winnerName: plaintiffName,
                summary: "The court finds for \(plaintiffName). \(defendantName) must accept responsibility with theatrical dignity.",
                guiltyVotes: guiltyVotes,
                notGuiltyVotes: notGuiltyVotes
            )
        }

        return VerdictResult(
            title: "Not Guilty",
            winnerName: defendantName,
            summary: "\(defendantName) walks free, possibly smugly. \(plaintiffName) may file an appeal after dessert.",
            guiltyVotes: guiltyVotes,
            notGuiltyVotes: notGuiltyVotes
        )
    }
}

import Foundation

struct VerdictResult: Equatable {
    let winnerName: String
    let summary: String
}

final class GameService {
    func createSession(deckTitle: String, playerNames: [String]) -> GameSession {
        let players = playerNames.filter { !$0.isEmpty }.map { Player(name: $0) }
        return GameSession(selectedDeckTitle: deckTitle, players: players)
    }

    func verdict(for votes: [String]) -> VerdictResult {
        let grouped = Dictionary(grouping: votes, by: { $0 })
        let winner = grouped.max { $0.value.count < $1.value.count }?.key ?? "The Court"
        return VerdictResult(winnerName: winner, summary: "The people have spoken. \(winner) wins this extremely serious case.")
    }
}

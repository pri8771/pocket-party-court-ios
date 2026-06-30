import Foundation
import Observation

/// The full-case state machine.
///
/// Drives one party game from setup → reveal → arguments → voting → verdict,
/// then loops to the next case / new round. It is intentionally free of SwiftUI
/// and SwiftData so every transition is unit-testable (CI proves the engine
/// headless). Persistence of *completed* cases is the view layer's job via
/// `makeCompletedSnapshot()`.
@Observable
final class GameStore {
    // MARK: State

    private(set) var phase: GamePhase = .setup
    private(set) var deck: DeckContent
    private(set) var players: [RoundPlayer]
    private(set) var currentCase: CaseContent?
    /// 1-based round counter; bumps on `newRound()`.
    private(set) var round: Int = 1
    /// Number of verdicts reached this session.
    private(set) var casesPlayed: Int = 0
    /// playerID → guilty(true)/notGuilty(false). Absent = not yet voted.
    private(set) var votes: [UUID: Bool] = [:]
    private(set) var lastResult: VerdictResult?
    /// playerID → cases won as a litigant. Drives the "crown a winner" finale.
    private(set) var scores: [UUID: Int] = [:]

    var argumentDuration: Int

    /// All cases for the deck, used as a reshuffling draw pile.
    private let allCases: [CaseContent]
    /// Cases not yet drawn this pass (reshuffles when exhausted).
    private var drawPile: [CaseContent]
    /// Deterministic shuffle counter so repeated draws vary without RNG in tests.
    private var drawSeed: Int = 0

    // MARK: Init

    init(deck: DeckContent, cases: [CaseContent], players: [RoundPlayer], argumentDuration: Int = 60) {
        self.deck = deck
        self.allCases = cases
        self.drawPile = cases
        self.players = JuryRules.assignRoles(to: players)
        self.argumentDuration = argumentDuration
    }

    // MARK: Derived

    var plaintiff: RoundPlayer? { JuryRules.player(players, role: .plaintiff) }
    var defendant: RoundPlayer? { JuryRules.player(players, role: .defendant) }
    var judge: RoundPlayer? { JuryRules.player(players, role: .judge) }
    var voters: [RoundPlayer] { JuryRules.voters(among: players) }

    var guiltyVotes: Int { votes.values.filter { $0 }.count }
    var notGuiltyVotes: Int { votes.values.filter { !$0 }.count }
    var allVotesCast: Bool { !voters.isEmpty && votes.count >= voters.count }

    var plaintiffName: String { plaintiff?.name ?? "Plaintiff" }
    var defendantName: String { defendant?.name ?? "Defendant" }

    /// Players ranked by cases won (desc), ties broken by entry order.
    var standings: [(player: RoundPlayer, score: Int)] {
        players
            .map { ($0, scores[$0.id] ?? 0) }
            .sorted { $0.1 > $1.1 }
    }

    /// The top scorer(s). Empty if nobody has won a case yet (all hung juries).
    var winners: [RoundPlayer] {
        let top = standings.first?.score ?? 0
        guard top > 0 else { return [] }
        return standings.filter { $0.score == top }.map(\.player)
    }

    func score(for player: RoundPlayer) -> Int { scores[player.id] ?? 0 }

    // MARK: Transitions

    /// setup → caseReveal. Draws the first case and locks in roles.
    func beginCase() {
        guard phase == .setup, !allCases.isEmpty else { return }
        players = JuryRules.assignRoles(to: players)
        drawNextCase()
        phase = .caseReveal
    }

    /// caseReveal → arguments.
    func startArguments() {
        guard phase == .caseReveal else { return }
        phase = .arguments
    }

    /// arguments → voting. Clears any stale votes.
    func goToVoting() {
        guard phase == .arguments else { return }
        votes = [:]
        phase = .voting
    }

    /// Records (or clears) a single voter's choice.
    func castVote(playerID: UUID, guilty: Bool?) {
        guard phase == .voting else { return }
        if let guilty {
            votes[playerID] = guilty
        } else {
            votes[playerID] = nil
        }
    }

    /// voting → verdict. Computes and stores the result (total function).
    @discardableResult
    func revealVerdict() -> VerdictResult? {
        guard phase == .voting, allVotesCast else { return nil }
        let result = VerdictEngine.result(
            guiltyVotes: guiltyVotes,
            notGuiltyVotes: notGuiltyVotes,
            plaintiffName: plaintiffName,
            defendantName: defendantName
        )
        lastResult = result
        awardPoint(for: result.verdict)
        casesPlayed += 1
        phase = .verdict
        return result
    }

    /// Awards the winning litigant a point. A hung jury awards nothing.
    private func awardPoint(for verdict: Verdict) {
        let winnerID: UUID?
        switch verdict {
        case .guilty: winnerID = plaintiff?.id
        case .notGuilty: winnerID = defendant?.id
        case .hungJury: winnerID = nil
        }
        if let winnerID { scores[winnerID, default: 0] += 1 }
    }

    /// verdict → caseReveal, rotating roles so a different pair argues and the
    /// spotlight (and scoring chances) move around the room. Reachable from
    /// every verdict (guilty / notGuilty / hungJury).
    func nextCase() {
        guard phase == .verdict else { return }
        votes = [:]
        rotateRoles()
        drawNextCase()
        phase = .caseReveal
    }

    /// verdict → caseReveal, rotating roles and bumping the round counter.
    /// Also reachable from every verdict.
    func newRound() {
        guard phase == .verdict else { return }
        round += 1
        votes = [:]
        rotateRoles()
        drawNextCase()
        phase = .caseReveal
    }

    /// verdict → finale. Shows the "crown the winner" leaderboard.
    func crownWinner() {
        guard phase == .verdict else { return }
        phase = .finale
    }

    /// finale → caseReveal. Starts a fresh game with the same roster, clearing
    /// scores and the draw pile.
    func playAgain() {
        restart()
        beginCase()
    }

    /// Hard reset back to setup, keeping the player roster and deck.
    func restart() {
        phase = .setup
        votes = [:]
        currentCase = nil
        round = 1
        casesPlayed = 0
        lastResult = nil
        scores = [:]
        drawPile = allCases
        players = JuryRules.assignRoles(to: players)
    }

    // MARK: Party-reality hardening (add/drop players mid-game)

    /// Adds a latecomer. Mid-game they join as jury so the active litigants and
    /// the in-progress vote are undisturbed.
    func addPlayer(name: String, emoji: String = "⚖️") {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, players.count < JuryRules.maxPlayers else { return }
        if phase == .setup {
            players.append(RoundPlayer(name: trimmed, emoji: emoji))
            players = JuryRules.assignRoles(to: players)
        } else {
            players.append(RoundPlayer(name: trimmed, emoji: emoji, role: .jury))
        }
    }

    /// Drops a player without ending the round. If a litigant or the judge
    /// leaves mid-case, roles are reassigned among the remaining players so the
    /// game can continue. Their vote (if any) is discarded.
    func removePlayer(id: UUID) {
        guard players.count > JuryRules.minPlayers else { return }
        let leaving = players.first { $0.id == id }
        players.removeAll { $0.id == id }
        votes[id] = nil

        let lostKeyRole = leaving.map { $0.role != .jury } ?? false
        if phase != .setup && lostKeyRole {
            players = JuryRules.assignRoles(to: players)
        } else if phase == .setup {
            players = JuryRules.assignRoles(to: players)
        }
    }

    // MARK: Snapshots

    /// Privacy-safe record of a completed case for History. Note: vote *totals*
    /// only — never who voted which way.
    struct CompletedSnapshot {
        let deckTitle: String
        let casePrompt: String
        let verdict: Verdict
        let verdictTitle: String
        let verdictSummary: String
        let guiltyVotes: Int
        let notGuiltyVotes: Int
        let players: [RoundPlayer]
    }

    func makeCompletedSnapshot() -> CompletedSnapshot? {
        guard let result = lastResult, let currentCase else { return nil }
        return CompletedSnapshot(
            deckTitle: deck.title,
            casePrompt: currentCase.prompt,
            verdict: result.verdict,
            verdictTitle: result.title,
            verdictSummary: result.summary,
            guiltyVotes: result.guiltyVotes,
            notGuiltyVotes: result.notGuiltyVotes,
            players: players
        )
    }

    // MARK: Private

    private func drawNextCase() {
        if drawPile.isEmpty { drawPile = allCases }
        guard !drawPile.isEmpty else { currentCase = nil; return }
        // Deterministic pick: index derived from a counter so the sequence
        // varies between draws but stays reproducible in tests (no RNG).
        drawSeed &+= 1
        let index = (drawSeed &* 2_654_435_761).magnitude % UInt(drawPile.count)
        currentCase = drawPile.remove(at: Int(index))
    }

    private func rotateRoles() {
        guard players.count > 1 else { return }
        let shifted = Array(players[1...] + players[..<1])
        players = JuryRules.assignRoles(to: shifted)
    }
}

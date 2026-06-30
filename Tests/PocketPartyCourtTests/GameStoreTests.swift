import XCTest
@testable import PocketPartyCourt

final class GameStoreTests: XCTestCase {
    private func makeStore(players n: Int, cases m: Int = 6) -> GameStore {
        let cases = (0..<m).map {
            CaseContent(id: "c\($0)", prompt: "Prompt \($0)", category: "cat",
                        plaintiffHint: "p", defendantHint: "d")
        }
        let players = (0..<n).map { RoundPlayer(name: "P\($0)") }
        return GameStore(deck: DeckContent(id: "d", title: "Deck", accentHex: "F0782C"),
                         cases: cases, players: players, argumentDuration: 60)
    }

    /// Casts votes among the current voters to force a specific verdict.
    private func castVotes(_ store: GameStore, for outcome: Verdict) {
        let voters = store.voters
        switch outcome {
        case .guilty:
            voters.forEach { store.castVote(playerID: $0.id, guilty: true) }
        case .notGuilty:
            voters.forEach { store.castVote(playerID: $0.id, guilty: false) }
        case .hungJury:
            for (i, v) in voters.enumerated() { store.castVote(playerID: v.id, guilty: i % 2 == 0) }
        }
    }

    // MARK: Happy path

    func testFullCaseFlow() {
        let s = makeStore(players: 4)
        XCTAssertEqual(s.phase, .setup)
        s.beginCase()
        XCTAssertEqual(s.phase, .caseReveal)
        XCTAssertNotNil(s.currentCase)
        XCTAssertNotNil(s.plaintiff)
        XCTAssertNotNil(s.defendant)

        s.startArguments()
        XCTAssertEqual(s.phase, .arguments)

        s.goToVoting()
        XCTAssertEqual(s.phase, .voting)

        // Gated: no verdict until everyone votes.
        XCTAssertNil(s.revealVerdict())
        XCTAssertEqual(s.phase, .voting)

        castVotes(s, for: .guilty)
        XCTAssertTrue(s.allVotesCast)
        let result = s.revealVerdict()
        XCTAssertEqual(result?.verdict, .guilty)
        XCTAssertEqual(s.phase, .verdict)
        XCTAssertEqual(s.casesPlayed, 1)
    }

    // MARK: Loops reachable from all three verdicts

    func testNextCaseFromEveryVerdict() {
        for outcome in Verdict.allCases {
            let s = makeStore(players: 4)
            s.beginCase(); s.startArguments(); s.goToVoting()
            castVotes(s, for: outcome)
            s.revealVerdict()
            XCTAssertEqual(s.lastResult?.verdict, outcome)

            s.nextCase()
            XCTAssertEqual(s.phase, .caseReveal, "nextCase stranded on \(outcome)")
            XCTAssertTrue(s.votes.isEmpty)
            XCTAssertNotNil(s.currentCase)
        }
    }

    func testNewRoundFromEveryVerdictRotatesRoles() {
        for outcome in Verdict.allCases {
            let s = makeStore(players: 4)
            s.beginCase()
            let firstJudge = s.judge?.id
            s.startArguments(); s.goToVoting()
            castVotes(s, for: outcome)
            s.revealVerdict()

            s.newRound()
            XCTAssertEqual(s.phase, .caseReveal, "newRound stranded on \(outcome)")
            XCTAssertEqual(s.round, 2)
            XCTAssertNotEqual(s.judge?.id, firstJudge, "roles did not rotate on \(outcome)")
        }
    }

    // MARK: Party-reality hardening

    func testAddPlayerMidVoteReopensTally() {
        let s = makeStore(players: 4)
        s.beginCase(); s.startArguments(); s.goToVoting()
        castVotes(s, for: .guilty)
        XCTAssertTrue(s.allVotesCast)

        s.addPlayer(name: "Latecomer")
        XCTAssertEqual(s.players.count, 5)
        XCTAssertEqual(s.players.last?.role, .jury)
        // New juror hasn't voted yet, so the verdict re-locks.
        XCTAssertFalse(s.allVotesCast)
    }

    func testRemoveLitigantReassignsRolesAndKeepsRound() {
        let s = makeStore(players: 5)
        s.beginCase()
        let plaintiffID = s.plaintiff!.id
        s.startArguments()

        s.removePlayer(id: plaintiffID)
        XCTAssertEqual(s.players.count, 4)
        XCTAssertNotNil(s.plaintiff, "a plaintiff must still exist after one leaves")
        XCTAssertNotNil(s.defendant)
        XCTAssertEqual(s.phase, .arguments, "removing a player must not end the round")
    }

    func testCannotRemoveBelowMinimum() {
        let s = makeStore(players: 2)
        s.beginCase()
        s.removePlayer(id: s.players[0].id)
        XCTAssertEqual(s.players.count, 2)
    }

    func testRestartReturnsToSetup() {
        let s = makeStore(players: 4)
        s.beginCase(); s.startArguments(); s.goToVoting()
        castVotes(s, for: .guilty)
        s.revealVerdict()

        s.restart()
        XCTAssertEqual(s.phase, .setup)
        XCTAssertEqual(s.round, 1)
        XCTAssertEqual(s.casesPlayed, 0)
        XCTAssertTrue(s.votes.isEmpty)
        XCTAssertNil(s.currentCase)
    }

    // MARK: Scoring + winner finale

    func testWinningLitigantScoresAPoint() {
        let s = makeStore(players: 4)
        s.beginCase(); s.startArguments(); s.goToVoting()
        let plaintiff = s.plaintiff!
        castVotes(s, for: .guilty)   // guilty → plaintiff wins
        s.revealVerdict()
        XCTAssertEqual(s.score(for: plaintiff), 1)
        XCTAssertEqual(s.standings.first?.player.id, plaintiff.id)
    }

    func testHungJuryAwardsNoPoints() {
        let s = makeStore(players: 4)
        s.beginCase(); s.startArguments(); s.goToVoting()
        castVotes(s, for: .hungJury)
        s.revealVerdict()
        XCTAssertTrue(s.winners.isEmpty)
        XCTAssertEqual(s.standings.map(\.score).reduce(0, +), 0)
    }

    func testScoresAccumulateAcrossCasesAndCrownAWinner() {
        let s = makeStore(players: 4, cases: 8)
        s.beginCase()
        for _ in 0..<3 {
            if s.phase == .verdict { s.nextCase() }
            s.startArguments(); s.goToVoting()
            castVotes(s, for: .guilty)   // current plaintiff wins each time
            s.revealVerdict()
        }
        let totalPoints = s.standings.map(\.score).reduce(0, +)
        XCTAssertEqual(totalPoints, 3)
        XCTAssertFalse(s.winners.isEmpty)

        s.crownWinner()
        XCTAssertEqual(s.phase, .finale)
    }

    func testCrownWinnerOnlyFromVerdict() {
        let s = makeStore(players: 4)
        s.beginCase()
        s.crownWinner()
        XCTAssertEqual(s.phase, .caseReveal)   // ignored — not at a verdict
    }

    func testPlayAgainClearsScoresAndStartsFresh() {
        let s = makeStore(players: 4)
        s.beginCase(); s.startArguments(); s.goToVoting()
        castVotes(s, for: .guilty)
        s.revealVerdict()
        s.crownWinner()

        s.playAgain()
        XCTAssertEqual(s.phase, .caseReveal)
        XCTAssertEqual(s.standings.map(\.score).reduce(0, +), 0)
        XCTAssertEqual(s.casesPlayed, 0)
    }

    // MARK: Snapshot privacy

    func testCompletedSnapshotHasTotalsNotPerVoter() {
        let s = makeStore(players: 4)
        s.beginCase(); s.startArguments(); s.goToVoting()
        castVotes(s, for: .guilty)
        s.revealVerdict()

        let snapshot = s.makeCompletedSnapshot()
        XCTAssertNotNil(snapshot)
        XCTAssertEqual(snapshot?.verdict, .guilty)
        XCTAssertEqual(snapshot?.guiltyVotes, s.guiltyVotes)
        XCTAssertEqual(snapshot?.notGuiltyVotes, s.notGuiltyVotes)
        // Players are carried for the roster, but the snapshot exposes no map of
        // who voted which way — only aggregate totals.
        XCTAssertEqual(snapshot?.players.count, 4)
    }
}

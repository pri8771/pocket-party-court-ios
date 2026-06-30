import XCTest
@testable import PocketPartyCourt

final class JuryRulesTests: XCTestCase {
    private func players(_ n: Int) -> [RoundPlayer] {
        (0..<n).map { RoundPlayer(name: "P\($0)") }
    }

    func testTwoPlayerRoles() {
        let roles = JuryRules.assignRoles(to: players(2)).map(\.role)
        XCTAssertEqual(roles, [.plaintiff, .defendant])
    }

    func testThreePlayerRoles() {
        let roles = JuryRules.assignRoles(to: players(3)).map(\.role)
        XCTAssertEqual(roles, [.judge, .plaintiff, .defendant])
    }

    func testFivePlayerRoles() {
        let roles = JuryRules.assignRoles(to: players(5)).map(\.role)
        XCTAssertEqual(roles, [.judge, .plaintiff, .defendant, .jury, .jury])
    }

    /// The old scaffold's bug: 3 players left nobody to vote. Voters must never
    /// be empty for any supported player count.
    func testVotersNeverEmpty() {
        for n in JuryRules.minPlayers...JuryRules.maxPlayers {
            let assigned = JuryRules.assignRoles(to: players(n))
            XCTAssertFalse(JuryRules.voters(among: assigned).isEmpty, "no voters for \(n) players")
        }
    }

    func testTwoPlayersBothVote() {
        let assigned = JuryRules.assignRoles(to: players(2))
        XCTAssertEqual(JuryRules.voters(among: assigned).count, 2)
    }

    func testThreePlayersJudgeVotes() {
        let assigned = JuryRules.assignRoles(to: players(3))
        let voters = JuryRules.voters(among: assigned)
        XCTAssertEqual(voters.count, 1)
        XCTAssertEqual(voters.first?.role, .judge)
    }

    func testVoterCountsExcludeLitigantsWhenJuryExists() {
        // 4 players -> judge + 1 jury vote (plaintiff & defendant excluded).
        XCTAssertEqual(JuryRules.voters(among: JuryRules.assignRoles(to: players(4))).count, 2)
        // 6 players -> judge + 3 jury.
        XCTAssertEqual(JuryRules.voters(among: JuryRules.assignRoles(to: players(6))).count, 4)
    }
}

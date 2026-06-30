import XCTest
@testable import PocketPartyCourt

/// The tally must be a *total function*: every vote distribution maps to exactly
/// one of three verdicts, with exact ties → hung jury.
final class VerdictEngineTests: XCTestCase {
    func testMajorityGuilty() {
        XCTAssertEqual(VerdictEngine.tally(guiltyVotes: 3, notGuiltyVotes: 1), .guilty)
    }

    func testMajorityNotGuilty() {
        XCTAssertEqual(VerdictEngine.tally(guiltyVotes: 1, notGuiltyVotes: 4), .notGuilty)
    }

    func testExactTieIsHungJury() {
        XCTAssertEqual(VerdictEngine.tally(guiltyVotes: 2, notGuiltyVotes: 2), .hungJury)
    }

    func testZeroZeroIsHungJury() {
        XCTAssertEqual(VerdictEngine.tally(guiltyVotes: 0, notGuiltyVotes: 0), .hungJury)
    }

    func testEveryDistributionUpToEightVotersResolves() {
        for total in 0...8 {
            for guilty in 0...total {
                let verdict = VerdictEngine.tally(guiltyVotes: guilty, notGuiltyVotes: total - guilty)
                XCTAssertTrue(Verdict.allCases.contains(verdict))
            }
        }
    }

    func testResultWinnerMapping() {
        XCTAssertEqual(VerdictEngine.result(guiltyVotes: 2, notGuiltyVotes: 0, plaintiffName: "Sam", defendantName: "Alex").winnerName, "Sam")
        XCTAssertEqual(VerdictEngine.result(guiltyVotes: 0, notGuiltyVotes: 2, plaintiffName: "Sam", defendantName: "Alex").winnerName, "Alex")
        XCTAssertEqual(VerdictEngine.result(guiltyVotes: 1, notGuiltyVotes: 1, plaintiffName: "Sam", defendantName: "Alex").winnerName, "The Drama")
    }

    func testResultCarriesTallies() {
        let result = VerdictEngine.result(guiltyVotes: 3, notGuiltyVotes: 2, plaintiffName: "Sam", defendantName: "Alex")
        XCTAssertEqual(result.guiltyVotes, 3)
        XCTAssertEqual(result.notGuiltyVotes, 2)
        XCTAssertEqual(result.verdict, .guilty)
    }
}

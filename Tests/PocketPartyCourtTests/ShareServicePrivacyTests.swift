import XCTest
@testable import PocketPartyCourt

/// The shared verdict text is a public artifact. It must carry the verdict and
/// winner but never the vote breakdown or per-voter information.
final class ShareServicePrivacyTests: XCTestCase {
    private let service = ShareService()

    private func text(for verdict: Verdict, guilty: Int, notGuilty: Int) -> String {
        let result = VerdictEngine.result(
            guiltyVotes: guilty, notGuiltyVotes: notGuilty,
            plaintiffName: "Sam", defendantName: "Alex"
        )
        XCTAssertEqual(result.verdict, verdict)
        return service.verdictCardText(deckTitle: "Friend Court", casePrompt: "Ate the last slice.", result: result)
    }

    func testIncludesVerdictWinnerAndTagline() {
        let card = text(for: .guilty, guilty: 3, notGuilty: 1)
        XCTAssertTrue(card.contains("GUILTY"))
        XCTAssertTrue(card.contains("Sam"))                 // winner
        XCTAssertTrue(card.contains(ShareService.tagline))
        XCTAssertTrue(card.contains("Ate the last slice."))
    }

    func testNeverLeaksVoteBreakdown() {
        for (v, g, n) in [(Verdict.guilty, 3, 1), (.notGuilty, 1, 4), (.hungJury, 2, 2)] {
            let card = text(for: v, guilty: g, notGuilty: n).lowercased()
            XCTAssertFalse(card.contains("vote"), "share text leaked vote wording")
            XCTAssertFalse(card.contains("•"), "share text included a tally separator")
            XCTAssertFalse(card.contains("jury voted"), "share text leaked jury detail")
        }
    }

    func testHungJuryWinnerIsNotAPlayerName() {
        let card = text(for: .hungJury, guilty: 2, notGuilty: 2)
        XCTAssertTrue(card.contains("The Drama"))
    }
}

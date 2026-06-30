import Foundation

/// The fully-resolved outcome of a case: the verdict plus the flavor text and
/// the tallies the reveal screen and share card need.
struct VerdictResult: Equatable {
    let verdict: Verdict
    let winnerName: String
    let summary: String
    let guiltyVotes: Int
    let notGuiltyVotes: Int

    var title: String { verdict.title }
}

/// Pure, deterministic verdict logic. No UI, no persistence — trivially unit
/// testable, which is exactly what CI exercises since the container can't run
/// the SwiftUI screens.
enum VerdictEngine {
    /// Maps a vote distribution to exactly one verdict. Total function:
    /// majority → guilty/notGuilty, exact tie (incl. 0–0) → hungJury.
    static func tally(guiltyVotes: Int, notGuiltyVotes: Int) -> Verdict {
        if guiltyVotes == notGuiltyVotes { return .hungJury }
        return guiltyVotes > notGuiltyVotes ? .guilty : .notGuilty
    }

    static func result(
        guiltyVotes: Int,
        notGuiltyVotes: Int,
        plaintiffName: String,
        defendantName: String
    ) -> VerdictResult {
        let verdict = tally(guiltyVotes: guiltyVotes, notGuiltyVotes: notGuiltyVotes)
        return VerdictResult(
            verdict: verdict,
            winnerName: winner(for: verdict, plaintiff: plaintiffName, defendant: defendantName),
            summary: summary(for: verdict, plaintiff: plaintiffName, defendant: defendantName),
            guiltyVotes: guiltyVotes,
            notGuiltyVotes: notGuiltyVotes
        )
    }

    static func winner(for verdict: Verdict, plaintiff: String, defendant: String) -> String {
        switch verdict {
        case .guilty: return plaintiff
        case .notGuilty: return defendant
        case .hungJury: return "The Drama"
        }
    }

    static func summary(for verdict: Verdict, plaintiff: String, defendant: String) -> String {
        switch verdict {
        case .guilty:
            return "The court finds for \(plaintiff). \(defendant) must accept responsibility with theatrical dignity — and possibly buy the next round of snacks."
        case .notGuilty:
            return "\(defendant) walks free, possibly smugly. \(plaintiff) may file an appeal after dessert."
        case .hungJury:
            return "The jury is hopelessly split, the gavel is tired, and everyone is sentenced to snacks before a rematch."
        }
    }
}

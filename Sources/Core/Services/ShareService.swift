import SwiftUI

/// Builds the privacy-safe verdict artifact that the group shares.
///
/// Hard rule (locked product decision): the shared card carries the case, the
/// verdict, the winner, and a fun stamp — and *never* the per-person votes,
/// the running vote breakdown, or anything said during arguments. What happens
/// in the room stays in the room; the card is the ad.
final class ShareService {
    /// Soft call-to-action appended to shared text so the artifact doubles as
    /// organic acquisition.
    static let tagline = "⚖️ Settled in Pocket Party Court — put your friends on trial."

    func verdictCardText(deckTitle: String, casePrompt: String, result: VerdictResult) -> String {
        """
        ⚖️ POCKET PARTY COURT — VERDICT
        Case: \(casePrompt)
        Verdict: \(result.verdict.stampText)
        Winner: \(result.winnerName)

        \(result.summary)

        \(Self.tagline)
        """
    }
}

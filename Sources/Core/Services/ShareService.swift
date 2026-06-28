import SwiftUI

final class ShareService {
    func verdictCardText(casePrompt: String, verdict: VerdictResult) -> String {
        "Pocket Party Court Verdict\nCase: \(casePrompt)\nWinner: \(verdict.winnerName)\n\(verdict.summary)"
    }
}

import SwiftUI

/// The three — and only three — terminal outcomes of a case.
///
/// Locked product decision: tallying votes is a *total function*. Every vote
/// distribution maps to exactly one of these, with an exact tie (or no
/// majority) resolving to `.hungJury`. The reveal UI therefore never has an
/// undefined state to fumble.
enum Verdict: String, Codable, CaseIterable, Identifiable, Hashable {
    case guilty
    case notGuilty
    case hungJury

    var id: String { rawValue }

    /// Headline shown on the verdict screen and history.
    var title: String {
        switch self {
        case .guilty: return "Guilty"
        case .notGuilty: return "Not Guilty"
        case .hungJury: return "Hung Jury"
        }
    }

    /// Short all-caps text for the rubber stamp.
    var stampText: String {
        switch self {
        case .guilty: return "GUILTY"
        case .notGuilty: return "NOT GUILTY"
        case .hungJury: return "HUNG JURY"
        }
    }

    var emoji: String {
        switch self {
        case .guilty: return "🔨"
        case .notGuilty: return "🕊️"
        case .hungJury: return "🤝"
        }
    }

    var tint: Color {
        switch self {
        case .guilty: return PPCColors.guilty
        case .notGuilty: return PPCColors.notGuilty
        case .hungJury: return PPCColors.hung
        }
    }
}

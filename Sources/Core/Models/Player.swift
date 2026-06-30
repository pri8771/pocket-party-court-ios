import SwiftUI
import SwiftData

enum PlayerRole: String, CaseIterable, Codable, Identifiable {
    case judge = "Judge"
    case plaintiff = "Plaintiff"
    case defendant = "Defendant"
    case jury = "Jury"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .judge: return "👩‍⚖️"
        case .plaintiff: return "🙋"
        case .defendant: return "🙅"
        case .jury: return "🧑‍🤝‍🧑"
        }
    }

    var tint: Color {
        switch self {
        case .judge: return PPCColors.robe
        case .plaintiff: return PPCColors.gavel
        case .defendant: return PPCColors.hung
        case .jury: return PPCColors.notGuilty
        }
    }

    /// One-line description of what this role does in the round.
    var blurb: String {
        switch self {
        case .judge: return "Keeps order and reads the verdict aloud."
        case .plaintiff: return "Brings the accusation. Argues first."
        case .defendant: return "Defends against the charge. Argues second."
        case .jury: return "Weighs the drama and votes."
        }
    }
}

@Model
final class Player {
    var id: UUID
    var name: String
    var emoji: String
    var score: Int
    var roleRawValue: String

    var role: PlayerRole {
        get { PlayerRole(rawValue: roleRawValue) ?? .jury }
        set { roleRawValue = newValue.rawValue }
    }

    init(id: UUID = UUID(), name: String, emoji: String = "⚖️", score: Int = 0, role: PlayerRole = .jury) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.score = score
        self.roleRawValue = role.rawValue
    }
}

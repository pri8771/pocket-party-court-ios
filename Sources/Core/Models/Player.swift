import Foundation
import SwiftData

enum PlayerRole: String, CaseIterable, Codable, Identifiable {
    case judge = "Judge"
    case plaintiff = "Plaintiff"
    case defendant = "Defendant"
    case jury = "Jury"

    var id: String { rawValue }
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

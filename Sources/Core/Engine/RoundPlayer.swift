import Foundation

/// A player as it exists *during* an in-progress game.
///
/// Deliberately a value type, separate from the SwiftData `Player` `@Model`.
/// The live game mutates roles, players join/leave, and rounds restart — we do
/// not want any of that churn touching the persistent store. Only when a case
/// completes do we snapshot the relevant players into `Player` records for
/// History.
struct RoundPlayer: Identifiable, Equatable, Codable, Hashable {
    let id: UUID
    var name: String
    var emoji: String
    var role: PlayerRole

    init(id: UUID = UUID(), name: String, emoji: String = "⚖️", role: PlayerRole = .jury) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.role = role
    }
}

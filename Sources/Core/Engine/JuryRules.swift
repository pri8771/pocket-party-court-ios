import Foundation

/// Pure rules for assigning courtroom roles and determining who votes.
///
/// These are the two places the old scaffold had a real bug: with exactly three
/// players the roles became judge/plaintiff/defendant and *no one* was left to
/// vote. Here, voting is defined so the voter set is **never empty**, which is
/// what keeps tallying a total function.
enum JuryRules {
    static let minPlayers = 2
    static let maxPlayers = 8

    /// Assigns theatrical roles by entry order.
    /// - 2 players → plaintiff, defendant.
    /// - 3+ players → judge, plaintiff, defendant, then everyone else is jury.
    static func assignRoles(to players: [RoundPlayer]) -> [RoundPlayer] {
        let count = players.count
        return players.enumerated().map { index, player in
            var updated = player
            updated.role = role(forIndex: index, playerCount: count)
            return updated
        }
    }

    static func role(forIndex index: Int, playerCount: Int) -> PlayerRole {
        switch (playerCount, index) {
        case (2, 0): return .plaintiff
        case (2, 1): return .defendant
        case (_, 0): return .judge
        case (_, 1): return .plaintiff
        case (_, 2): return .defendant
        default: return .jury
        }
    }

    /// The players who cast votes this round.
    ///
    /// The two litigants (plaintiff & defendant) argue, they don't judge their
    /// own case — so the jury plus the judge vote. If that leaves no one (the
    /// 2-player game), *everyone* votes so a verdict is always reachable.
    static func voters(among players: [RoundPlayer]) -> [RoundPlayer] {
        let nonLitigants = players.filter { $0.role != .plaintiff && $0.role != .defendant }
        return nonLitigants.isEmpty ? players : nonLitigants
    }

    static func player(_ players: [RoundPlayer], role: PlayerRole) -> RoundPlayer? {
        players.first { $0.role == role }
    }
}

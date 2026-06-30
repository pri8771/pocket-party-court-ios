import SwiftUI

/// The "crown the winner" finale: a leaderboard of cases won, with the top
/// scorer(s) crowned. Reached from the verdict screen when the group ends the
/// game.
struct WinnerView: View {
    let store: GameStore
    var onExit: () -> Void

    @State private var appeared = false

    private var winners: [RoundPlayer] { store.winners }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 22) {
                    Text("FINAL VERDICT")
                        .ppcEyebrow(PPCColors.brass)
                        .padding(.top, 12)

                    crown

                    leaderboard

                    actions
                }
                .padding(20)
                .padding(.bottom, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)
            }
            ConfettiView(pieceCount: 90).ignoresSafeArea()
        }
        .onAppear {
            Haptics.success()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { appeared = true }
        }
    }

    private var crown: some View {
        VStack(spacing: 10) {
            Text("👑").font(.system(size: 72))
            if winners.isEmpty {
                Text("No clear winner")
                    .font(PPCTypography.hero)
                    .foregroundStyle(PPCColors.ink)
                Text("Every case ended in a hung jury — the drama takes the crown.")
                    .font(PPCTypography.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(PPCColors.inkSecondary)
                    .padding(.horizontal, 24)
            } else {
                Text(winnerNames)
                    .font(PPCTypography.hero)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(PPCColors.ink)
                Text(winners.count > 1 ? "share the crown" : "wins the court")
                    .ppcEyebrow(PPCColors.gavel)
            }
        }
    }

    private var leaderboard: some View {
        PPCCard {
            VStack(spacing: 0) {
                ForEach(Array(store.standings.enumerated()), id: \.element.player.id) { index, entry in
                    HStack(spacing: 12) {
                        Text(medal(for: index))
                            .font(.title3)
                            .frame(width: 30)
                        Text(entry.player.emoji)
                        Text(entry.player.name)
                            .font(PPCTypography.bodyEmphasis)
                            .foregroundStyle(PPCColors.ink)
                        Spacer()
                        Text("^[\(entry.score) case](inflect: true)")
                            .font(PPCTypography.caption)
                            .foregroundStyle(PPCColors.inkSecondary)
                        Text("\(entry.score)")
                            .font(.system(.title3, design: .rounded).weight(.heavy))
                            .foregroundStyle(entry.score > 0 ? PPCColors.gavel : PPCColors.inkSecondary)
                            .frame(minWidth: 24)
                    }
                    .padding(.vertical, 10)
                    if index < store.standings.count - 1 {
                        Divider().overlay(PPCColors.hairline)
                    }
                }
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            PPCPrimaryButton(title: "Play Again", icon: "arrow.counterclockwise") {
                store.playAgain()
            }
            PPCSecondaryButton(title: "Back to Decks", icon: "house.fill") {
                onExit()
            }
        }
    }

    private var winnerNames: String {
        let names = winners.map(\.name)
        switch names.count {
        case 0: return ""
        case 1: return names[0]
        case 2: return "\(names[0]) & \(names[1])"
        default: return names.dropLast().joined(separator: ", ") + " & " + names.last!
        }
    }

    private func medal(for index: Int) -> String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "•"
        }
    }
}

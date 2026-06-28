import SwiftUI

struct CaseRevealView: View {
    let deck: CaseDeck
    let gameCase: GameCase
    let players: [Player]
    let argumentDuration: Int

    var body: some View {
        VStack(spacing: 24) {
            Text("The Case")
                .font(PPCTypography.title)
            Text(deck.title)
                .font(PPCTypography.caption)
                .foregroundStyle(.secondary)
            PPCCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text(gameCase.category.uppercased())
                        .font(PPCTypography.caption)
                        .foregroundStyle(PPCColors.gavel)
                    Text(gameCase.prompt)
                        .font(PPCTypography.title)
                    Divider()
                    Text("Plaintiff: \(players.first(where: { $0.role == .plaintiff })?.name ?? "Plaintiff")")
                    Text("Defendant: \(players.first(where: { $0.role == .defendant })?.name ?? "Defendant")")
                }
            }
            NavigationLink("Start Arguments", destination: TimerView(deck: deck, gameCase: gameCase, players: players, duration: argumentDuration))
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(PPCColors.background)
        .navigationTitle("Case Reveal")
    }
}

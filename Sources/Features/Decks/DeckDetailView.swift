import SwiftUI

struct DeckDetailView: View {
    let deck: CaseDeck

    private var sortedCases: [GameCase] { deck.cases.sorted { $0.id < $1.id } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                ForEach(sortedCases) { gameCase in
                    caseRow(gameCase)
                }
            }
            .padding(20)
        }
        .ppcScreenBackground()
        .navigationTitle(deck.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(deck.accent.opacity(0.16))
                Text(deck.icon).font(.system(size: 34))
            }
            .frame(width: 66, height: 66)
            VStack(alignment: .leading, spacing: 4) {
                Text(deck.deckDescription).font(PPCTypography.callout).foregroundStyle(PPCColors.ink)
                HStack(spacing: 6) {
                    PPCTag(text: "\(deck.cases.count) cases", tint: deck.accent)
                    if deck.isWorkSafe { PPCTag(text: "Work-safe", tint: PPCColors.notGuilty) }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.bottom, 4)
    }

    private func caseRow(_ gameCase: GameCase) -> some View {
        PPCCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(gameCase.prompt)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(PPCColors.ink)
                PPCTag(text: gameCase.category, tint: deck.accent)
            }
        }
    }
}

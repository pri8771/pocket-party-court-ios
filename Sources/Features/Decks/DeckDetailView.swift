import SwiftUI

struct DeckDetailView: View {
    let deck: CaseDeck

    var body: some View {
        List(deck.cases) { gameCase in
            VStack(alignment: .leading, spacing: 6) {
                Text(gameCase.prompt)
                    .font(PPCTypography.body)
                Text(gameCase.category.uppercased())
                    .font(PPCTypography.caption)
                    .foregroundStyle(PPCColors.gavel)
            }
        }
        .navigationTitle(deck.title)
    }
}

import SwiftData
import SwiftUI

struct DeckListView: View {
    @Query(sort: \CaseDeck.sortIndex) private var decks: [CaseDeck]

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("Every prompt is local to your device. Tap a deck to read its cases.")
                    .font(PPCTypography.caption)
                    .foregroundStyle(PPCColors.inkSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(decks) { deck in
                    NavigationLink {
                        DeckDetailView(deck: deck)
                    } label: {
                        DeckCard(deck: deck)
                    }
                    .buttonStyle(PPCPressStyle())
                }
            }
            .padding(20)
        }
        .ppcScreenBackground()
        .navigationTitle("All Decks")
        .navigationBarTitleDisplayMode(.inline)
    }
}

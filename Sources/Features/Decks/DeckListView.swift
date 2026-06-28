import SwiftData
import SwiftUI

struct DeckListView: View {
    @Query(sort: \CaseDeck.title) private var decks: [CaseDeck]

    var body: some View {
        List(decks) { deck in
            NavigationLink(destination: DeckDetailView(deck: deck)) {
                VStack(alignment: .leading) {
                    Text("\(deck.icon) \(deck.title)")
                        .font(PPCTypography.title)
                    Text(deck.deckDescription)
                        .font(PPCTypography.caption)
                }
            }
        }
        .navigationTitle("Decks")
    }
}

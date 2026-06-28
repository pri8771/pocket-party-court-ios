import SwiftUI

struct DeckListView: View {
    private let decks = DeckService().loadStarterDecks()

    var body: some View {
        List(decks) { deck in
            NavigationLink(destination: DeckDetailView(deck: deck)) {
                VStack(alignment: .leading) {
                    Text("\(deck.icon) \(deck.title)")
                        .font(PPCTypography.title)
                    Text(deck.description)
                        .font(PPCTypography.caption)
                }
            }
        }
        .navigationTitle("Decks")
    }
}

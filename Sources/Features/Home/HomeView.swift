import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CaseDeck.title) private var decks: [CaseDeck]
    @State private var viewModel = HomeViewModel()
    @State private var seedingError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                PPCColors.background.ignoresSafeArea()
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("⚖️ Pocket Party Court")
                                .font(PPCTypography.hero)
                            Text(viewModel.subtitle)
                                .font(PPCTypography.body)
                                .foregroundStyle(.secondary)
                        }
                        .listRowBackground(Color.clear)
                    }

                    if let seedingError {
                        Section("Deck loading issue") {
                            Text(seedingError)
                                .foregroundStyle(.red)
                        }
                    }

                    Section("Choose a deck") {
                        if decks.isEmpty {
                            ProgressView("Loading starter decks…")
                        } else {
                            ForEach(decks) { deck in
                                NavigationLink(destination: GameSetupView(deck: deck)) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("\(deck.icon) \(deck.title)")
                                            .font(PPCTypography.title)
                                        Text(deck.deckDescription)
                                            .font(PPCTypography.caption)
                                            .foregroundStyle(.secondary)
                                        Text("\(deck.cases.count) cases")
                                            .font(PPCTypography.caption)
                                            .foregroundStyle(PPCColors.gavel)
                                    }
                                    .padding(.vertical, 6)
                                }
                            }
                        }
                    }

                    Section {
                        NavigationLink("Browse All Cases", destination: DeckListView())
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Home")
            .task {
                do {
                    try DeckService().seedStarterDecksIfNeeded(in: modelContext)
                } catch {
                    seedingError = "Starter decks could not be loaded: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

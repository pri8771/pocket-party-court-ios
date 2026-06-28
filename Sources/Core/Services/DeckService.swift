import Foundation
import SwiftData

struct StarterDeckDTO: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let cases: [StarterCaseDTO]
}

struct StarterCaseDTO: Codable, Identifiable {
    let id: String
    let prompt: String
    let category: String
}

struct StarterDeckCatalog: Codable {
    let decks: [StarterDeckDTO]
}

final class DeckService {
    func loadStarterDecks() -> [StarterDeckDTO] {
        guard let url = Bundle.main.url(forResource: "StarterDecks", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let catalog = try? JSONDecoder().decode(StarterDeckCatalog.self, from: data) else {
            return []
        }
        return catalog.decks
    }

    @MainActor
    func seedStarterDecksIfNeeded(in context: ModelContext) throws {
        var descriptor = FetchDescriptor<CaseDeck>()
        descriptor.fetchLimit = 1

        guard try context.fetch(descriptor).isEmpty else { return }

        for starterDeck in loadStarterDecks() {
            let cases = starterDeck.cases.map { starterCase in
                GameCase(prompt: starterCase.prompt, category: starterCase.category)
            }
            context.insert(
                CaseDeck(
                    title: starterDeck.title,
                    deckDescription: starterDeck.description,
                    icon: starterDeck.icon,
                    cases: cases
                )
            )
        }

        try context.save()
    }
}

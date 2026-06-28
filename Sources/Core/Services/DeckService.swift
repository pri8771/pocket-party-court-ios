import Foundation

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
}

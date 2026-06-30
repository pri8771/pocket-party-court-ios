import Foundation
import SwiftData

struct StarterDeckDTO: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let cases: [StarterCaseDTO]
    // Optional metadata — defaulted so older/minimal JSON still decodes.
    var accentHex: String?
    var isWorkSafe: Bool?
    var isPremium: Bool?
    var productID: String?
}

struct StarterCaseDTO: Codable, Identifiable {
    let id: String
    let prompt: String
    let category: String
    var plaintiffHint: String?
    var defendantHint: String?
}

struct StarterDeckCatalog: Codable {
    let decks: [StarterDeckDTO]
}

enum DeckServiceError: LocalizedError {
    case missingStarterDeckResource

    var errorDescription: String? {
        switch self {
        case .missingStarterDeckResource:
            return "StarterDecks.json could not be found in the app bundle."
        }
    }
}

final class DeckService {
    func loadStarterDecks() throws -> [StarterDeckDTO] {
        guard let url = Bundle.main.url(forResource: "StarterDecks", withExtension: "json") else {
            throw DeckServiceError.missingStarterDeckResource
        }
        return try loadStarterDecks(from: url)
    }

    func loadStarterDecks(from url: URL) throws -> [StarterDeckDTO] {
        let data = try Data(contentsOf: url)
        return try decodeStarterDecks(from: data)
    }

    func decodeStarterDecks(from data: Data) throws -> [StarterDeckDTO] {
        try JSONDecoder().decode(StarterDeckCatalog.self, from: data).decks
    }

    @MainActor
    func seedStarterDecksIfNeeded(in context: ModelContext) throws {
        try seedStarterDecks(loadStarterDecks(), in: context)
    }

    @MainActor
    func seedStarterDecks(_ starterDecks: [StarterDeckDTO], in context: ModelContext) throws {
        var didInsert = false

        for (index, starterDeck) in starterDecks.enumerated() {
            let deck: CaseDeck
            if let existingDeck = try existingDeck(id: starterDeck.id, in: context) {
                deck = existingDeck
                // Keep bundled metadata fresh on re-seed (icons, accent, flags).
                deck.title = starterDeck.title
                deck.deckDescription = starterDeck.description
                deck.icon = starterDeck.icon
                deck.sortIndex = index
                deck.accentHex = starterDeck.accentHex ?? deck.accentHex
                deck.isWorkSafe = starterDeck.isWorkSafe ?? deck.isWorkSafe
                deck.isPremium = starterDeck.isPremium ?? deck.isPremium
                deck.productID = starterDeck.productID ?? deck.productID
            } else {
                deck = CaseDeck(
                    id: starterDeck.id,
                    title: starterDeck.title,
                    deckDescription: starterDeck.description,
                    icon: starterDeck.icon,
                    sortIndex: index,
                    accentHex: starterDeck.accentHex ?? "F0782C",
                    isWorkSafe: starterDeck.isWorkSafe ?? false,
                    isPremium: starterDeck.isPremium ?? false,
                    productID: starterDeck.productID ?? ""
                )
                context.insert(deck)
                didInsert = true
            }

            for starterCase in starterDeck.cases where try existingCase(id: starterCase.id, in: context) == nil {
                deck.cases.append(
                    GameCase(
                        id: starterCase.id,
                        prompt: starterCase.prompt,
                        category: starterCase.category,
                        plaintiffHint: starterCase.plaintiffHint ?? "Make your best dramatic opening statement.",
                        defendantHint: starterCase.defendantHint ?? "Deny everything with confidence."
                    )
                )
                didInsert = true
            }
        }

        if didInsert || context.hasChanges {
            try context.save()
        }
    }

    @MainActor
    private func existingDeck(id: String, in context: ModelContext) throws -> CaseDeck? {
        var descriptor = FetchDescriptor<CaseDeck>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    @MainActor
    private func existingCase(id: String, in context: ModelContext) throws -> GameCase? {
        var descriptor = FetchDescriptor<GameCase>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}

extension CaseDeck {
    /// Value-type content for the engine.
    var content: DeckContent { DeckContent(id: id, title: title, accentHex: accentHex) }

    var caseContents: [CaseContent] {
        cases.map {
            CaseContent(
                id: $0.id,
                prompt: $0.prompt,
                category: $0.category,
                plaintiffHint: $0.plaintiffHint,
                defendantHint: $0.defendantHint
            )
        }
    }
}

import SwiftData
import XCTest
@testable import PocketPartyCourt

@MainActor
final class DeckServiceTests: XCTestCase {
    func testDecodePreservesJSONIDs() throws {
        let json = #"{"decks":[{"id":"deck-a","title":"Deck A","description":"Desc","icon":"⚖️","cases":[{"id":"case-a","prompt":"Prompt","category":"cat"}]}]}"#.data(using: .utf8)!
        let decks = try DeckService().decodeStarterDecks(from: json)
        XCTAssertEqual(decks.first?.id, "deck-a")
        XCTAssertEqual(decks.first?.cases.first?.id, "case-a")
    }

    func testDecodePropagatesJSONErrors() {
        XCTAssertThrowsError(try DeckService().decodeStarterDecks(from: Data("not json".utf8)))
    }

    func testSeedingIsGranularAndIdempotent() throws {
        let container = try ModelContainer(for: CaseDeck.self, GameCase.self, GameSession.self, Player.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        let service = DeckService()
        let decks = [StarterDeckDTO(id: "deck-a", title: "Deck A", description: "Desc", icon: "⚖️", cases: [StarterCaseDTO(id: "case-a", prompt: "Prompt A", category: "cat")])]

        try service.seedStarterDecks(decks, in: context)
        try service.seedStarterDecks(decks, in: context)

        XCTAssertEqual(try context.fetch(FetchDescriptor<CaseDeck>()).map(\.id), ["deck-a"])
        XCTAssertEqual(try context.fetch(FetchDescriptor<GameCase>()).map(\.id), ["case-a"])
    }
}

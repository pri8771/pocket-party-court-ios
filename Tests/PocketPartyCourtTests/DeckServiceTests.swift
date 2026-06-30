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

    func testDecodeReadsDeckMetadata() throws {
        let json = #"{"decks":[{"id":"d","title":"T","description":"D","icon":"💼","accentHex":"3E7BD6","isWorkSafe":true,"isPremium":true,"productID":"com.x.deck","cases":[{"id":"c","prompt":"P","category":"cat","plaintiffHint":"ph","defendantHint":"dh"}]}]}"#.data(using: .utf8)!
        let deck = try DeckService().decodeStarterDecks(from: json).first
        XCTAssertEqual(deck?.accentHex, "3E7BD6")
        XCTAssertEqual(deck?.isWorkSafe, true)
        XCTAssertEqual(deck?.isPremium, true)
        XCTAssertEqual(deck?.productID, "com.x.deck")
        XCTAssertEqual(deck?.cases.first?.plaintiffHint, "ph")
    }

    func testBundledCatalogDecodesAndIsFree() throws {
        // The shipped catalog must stay decodable; v1 ships no paid decks.
        let decks = try DeckService().loadStarterDecks()
        XCTAssertGreaterThanOrEqual(decks.count, 4)
        XCTAssertTrue(decks.contains { $0.isWorkSafe == true })
        XCTAssertFalse(decks.contains { $0.isPremium == true }, "v1 ships no premium decks")
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

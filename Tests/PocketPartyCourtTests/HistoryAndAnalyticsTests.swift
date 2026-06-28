import SwiftData
import SwiftUI
import XCTest
@testable import PocketPartyCourt

@MainActor
final class HistoryAndAnalyticsTests: XCTestCase {
    func testCompletedSessionCanPopulateHistoryQuery() throws {
        let container = try ModelContainer(for: CaseDeck.self, GameCase.self, GameSession.self, Player.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        context.insert(GameSession(completedAt: Date(timeIntervalSince1970: 1), selectedDeckTitle: "Friend Court", casePrompt: "Prompt", verdictTitle: "Guilty"))
        try context.save()

        let descriptor = FetchDescriptor<GameSession>(predicate: #Predicate { $0.completedAt != nil }, sortBy: [SortDescriptor(\.completedAt, order: .reverse)])
        let sessions = try context.fetch(descriptor)
        XCTAssertEqual(sessions.first?.selectedDeckTitle, "Friend Court")
        XCTAssertEqual(sessions.first?.verdictTitle, "Guilty")
    }

    func testAnalyticsServiceRecordsRequiredEventsInDebug() {
        #if DEBUG
        AnalyticsService.shared.resetForTesting()
        let required: [AnalyticsEvent] = [.gameStarted, .deckSelected, .caseDrawn, .timerCompleted, .voteCompleted, .verdictGenerated, .sessionSaved, .historyViewed]
        required.forEach { AnalyticsService.shared.track($0) }
        XCTAssertEqual(AnalyticsService.shared.trackedEvents, required)
        #endif
    }
}

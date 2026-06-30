import SwiftData
import SwiftUI

@main
struct PocketPartyCourtApp: App {
    @State private var store = StoreService.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CaseDeck.self,
            GameCase.self,
            GameSession.self,
            Player.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // The store schema is local-only; if it is ever incompatible, fall
            // back to a fresh in-memory container so the app still launches
            // rather than hard-crashing a paying user's device.
            do {
                return try ModelContainer(
                    for: schema,
                    configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
                )
            } catch {
                fatalError("Could not create SwiftData container: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(store)
                .tint(PPCColors.gavel)
                .onAppear { AnalyticsService.shared.track(.appOpened) }
        }
        .modelContainer(sharedModelContainer)
    }
}

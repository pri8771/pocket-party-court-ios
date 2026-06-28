import Foundation

protocol AnalyticsTracking: AnyObject {
    func track(_ event: AnalyticsEvent)
}

final class AnalyticsService: AnalyticsTracking {
    static let shared = AnalyticsService()
    private init() {}

    #if DEBUG
    private(set) var trackedEvents: [AnalyticsEvent] = []

    func resetForTesting() {
        trackedEvents.removeAll()
    }
    #endif

    func track(_ event: AnalyticsEvent) {
        #if DEBUG
        trackedEvents.append(event)
        print("Analytics event: \(event.rawValue)")
        #endif
    }
}

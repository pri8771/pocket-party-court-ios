import Foundation

final class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}

    func track(_ event: AnalyticsEvent) {
        #if DEBUG
        print("Analytics event: \(event.rawValue)")
        #endif
    }
}

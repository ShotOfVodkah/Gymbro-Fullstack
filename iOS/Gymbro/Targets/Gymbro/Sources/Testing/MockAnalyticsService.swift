import Foundation
import GymbroTypes

final class MockAnalyticsService: AnalyticsService {
    func track(_ event: AnalyticsEvent) {}
}

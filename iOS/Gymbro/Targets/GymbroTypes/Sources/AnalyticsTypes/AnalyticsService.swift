import Foundation

public protocol AnalyticsService: AnyObject {
    func track(_ event: AnalyticsEvent)
}

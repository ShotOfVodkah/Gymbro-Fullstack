import Foundation
import SwiftUI
import GymbroNavigation
import GymbroTypes

public final class FeedsCalendarFactoryImpl {
    
    private var viewModelCache: [CalendarScreenInput: FeedsCalendarViewModel] = [:]
    
    public init() {}
    
    @MainActor
    public func makeView(
        input: CalendarScreenInput,
        router: any Router,
        analytics: any AnalyticsService
    ) -> some View {
        if let cached = viewModelCache[input] {
            return FeedsCalendarView(viewModel: cached)
        } else {
            let viewModel = FeedsCalendarViewModel(input: input, router: router, analytics: analytics)
            viewModelCache[input] = viewModel
            return FeedsCalendarView(viewModel: viewModel)
        }
    }
}

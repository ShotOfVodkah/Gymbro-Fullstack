import Foundation
import SwiftUI
import GymbroNavigation

public final class FeedsCalendarFactoryImpl {
    
    private var viewModelCache: [CalendarScreenInput: FeedsCalendarViewModel] = [:]
    
    public init() {}
    
    @MainActor
    public func makeView(
        input: CalendarScreenInput,
        router: any Router
    ) -> some View {
        if let cached = viewModelCache[input] {
            return FeedsCalendarView(viewModel: cached)
        } else {
            let viewModel = FeedsCalendarViewModel(input: input, router: router)
            viewModelCache[input] = viewModel
            return FeedsCalendarView(viewModel: viewModel)
        }
    }
}

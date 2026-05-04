import Foundation
import SwiftUI
import GymbroNavigation
import GymbroNetwork
import GymbroTypes

public final class FeedsCalendarFactoryImpl {
    
    private var cachedUserID: String?
    private var viewModelCache: [CalendarScreenInput: FeedsCalendarViewModel] = [:]
    
    public init() {}
    
    @MainActor
    public func makeView(
        input: CalendarScreenInput,
        router: any Router,
        client: FeedsClient,
        analytics: any AnalyticsService
    ) -> some View {
        let currentUserID = AppMicroservices.tokens.userId ?? ""

        if cachedUserID != currentUserID {
            viewModelCache.removeAll()
            cachedUserID = currentUserID
            FeedsStateInvalidationCenter.shared.invalidate(.accountChanged)
        }
        
        if let cached = viewModelCache[input] {
            return FeedsCalendarView(viewModel: cached)
        }
        
        let service = FeedsCalendarServiceImpl(client: client)
        let viewModel = FeedsCalendarViewModel(
            input: input,
            router: router,
            service: service,
            analytics: analytics
        )
        viewModelCache[input] = viewModel
        
        return FeedsCalendarView(viewModel: viewModel)
    }
}

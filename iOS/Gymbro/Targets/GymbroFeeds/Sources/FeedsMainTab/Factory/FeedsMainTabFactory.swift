import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation
import GymbroTypes

public final class FeedsMainTabFactoryImpl {

    private var cachedUserID: String?
    private var viewModelCache: FeedsMainTabViewModel?

    public init() {}

    @MainActor
    public func makeView(
        router: any Router,
        client: any FeedsClientProtocol,
        analytics: any AnalyticsService,
        perksEvents: any PerksEventTrackingService
    ) -> some View {
        let currentUserID = AppMicroservices.tokens.userId ?? ""
        
        if cachedUserID != currentUserID {
            viewModelCache = nil
            cachedUserID = currentUserID
            FeedsStateInvalidationCenter.shared.invalidate(.accountChanged)
        }
        
        guard let viewModelCache else {
            let service = FeedsMainTabServiceImpl(client: client, perksEvents: perksEvents)
            let viewModel = FeedsMainTabViewModel(
                router: router,
                service: service,
                analytics: analytics,
                invalidationCenter: .shared
            )
            self.viewModelCache = viewModel
            return FeedsMainTabView(viewModel: viewModel)
        }
        
        return FeedsMainTabView(viewModel: viewModelCache)
    }
}

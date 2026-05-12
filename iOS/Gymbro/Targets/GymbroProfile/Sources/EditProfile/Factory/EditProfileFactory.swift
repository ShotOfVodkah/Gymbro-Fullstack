import Foundation
import SwiftUI
import GymbroNavigation
import GymbroNetwork
import GymbroTypes

public final class EditProfileFactoryImpl {
    
    private var cachedUserID: String?
    private var viewModelCache: EditProfileViewModel?
    
    public init() {}
    
    @MainActor
    public func makeView(
        router: any Router,
        client: any ProfileClientProtocol,
        analytics: any AnalyticsService
    ) -> some View {
        let currentUserID = AppMicroservices.tokens.userId ?? ""

        if cachedUserID != currentUserID {
            viewModelCache = nil
            cachedUserID = currentUserID
            ProfileStateInvalidationCenter.shared.invalidate(.accountChanged)
        }

        if let viewModelCache {
            return EditProfileView(viewModel: viewModelCache)
        }
        
        let service = EditProfileServiceImpl(client: client)
        let viewModel = EditProfileViewModel(
            router: router,
            service: service,
            analytics: analytics
        )
        self.viewModelCache = viewModel
        
        return EditProfileView(viewModel: viewModel)
    }
}

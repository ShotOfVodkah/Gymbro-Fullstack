import Foundation
import SwiftUI
import GymbroNavigation
import GymbroTypes

public final class EditProfileFactoryImpl {
    
    private var viewModelCache: EditProfileViewModel?
    
    public init() {}
    
    @MainActor
    public func makeView(router: any Router, analytics: any AnalyticsService) -> some View {
        if let viewModelCache {
            return EditProfileView(viewModel: viewModelCache)
        }
        
        let service = EditProfileServiceImpl()
        let viewModel = EditProfileViewModel(
            router: router,
            service: service,
            analytics: analytics
        )
        self.viewModelCache = viewModel
        
        return EditProfileView(viewModel: viewModel)
    }
}

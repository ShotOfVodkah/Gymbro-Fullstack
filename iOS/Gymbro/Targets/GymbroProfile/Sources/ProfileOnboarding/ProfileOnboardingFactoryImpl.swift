import Foundation
import SwiftUI
import GymbroNetwork
import GymbroTypes

public final class ProfileOnboardingFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(
        client: ProfileClient,
        analytics: any AnalyticsService,
        onCompleted: @escaping () -> Void
    ) -> some View {
        let service = EditProfileServiceImpl(client: client)
        let viewModel = ProfileOnboardingViewModel(
            service: service,
            analytics: analytics,
            onCompleted: onCompleted
        )
        return ProfileOnboardingView(viewModel: viewModel)
    }
}

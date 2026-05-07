import Foundation
import SwiftUI
import GymbroNavigation
import GymbroNetwork
import GymbroTypes

public final class WorkoutShareFactoryImpl {
    
    public init() {}

    @MainActor
    public func makeView(
        input: WorkoutShareInput,
        router: any Router,
        client: any FeedsClientProtocol,
        analytics: any AnalyticsService,
        perksEvents: any PerksEventTrackingService
    ) -> some View {
        let service = WorkoutShareServiceImpl(feedsClient: client, perksEvents: perksEvents)
        let viewModel = WorkoutShareViewModel(
            input: input,
            router: router,
            service: service,
            analytics: analytics
        )
        return WorkoutShareView(viewModel: viewModel)
    }
}

import Foundation
import SwiftUI

import GymbroNavigation
import GymbroNetwork
import GymbroTypes

public final class WorkoutPlayerFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(
        id: String,
        router: any Router,
        modelModifier: WorkoutsModelModifier,
        workoutsRepository: WorkoutsCacheRepository,
        actionsRepository: OfflineActionsRepository,
        client: WorkoutsClient,
        feedsClient: FeedsClient,
        analytics: any AnalyticsService,
        streakWidget: StreakWidgetControlling,
        activityCalendarWidget: ActivityCalendarWidgetControlling,
        perksEvents: any PerksEventTrackingService
    ) -> some View {
        guard let viewModelCache, id == idCache else {
            let service = WorkoutPlayerServiceImpl(
                client: client,
                feedsClient: feedsClient,
                workoutsRepository: workoutsRepository,
                actionsRepository: actionsRepository,
                streakWidget: streakWidget,
                activityCalendarWidget: activityCalendarWidget,
                perksEvents: perksEvents
            )
            let viewModel = WorkoutPlayerViewModel(
                id: id,
                router: router,
                modelModifier: modelModifier,
                service: service,
                analytics: analytics
            )
            viewModelCache = viewModel
            idCache = id
            return WorkoutPlayerView(viewModel: viewModel)
        }
        return WorkoutPlayerView(viewModel: viewModelCache)
    }

    private var idCache: String?
    private var viewModelCache: WorkoutPlayerViewModel?
}

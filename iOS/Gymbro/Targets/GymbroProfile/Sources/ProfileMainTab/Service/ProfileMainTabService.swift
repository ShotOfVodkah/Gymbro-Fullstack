import Foundation
import SwiftUI
import GymbroNetwork
import GymbroTypes

protocol ProfileMainTabService {
    func fetchScreen(mode: ProfileViewMode) async throws -> ProfileMainScreenModel
    func createDirectChat(with personID: String) async throws -> ChatSessionInput
    func toggleFollow(for userID: Int, isFollowing: Bool) async throws
    func trackProfileOpened(mode: ProfileViewMode) async
}

final class ProfileMainServiceImpl: ProfileMainTabService {
    
    init(gateway: any ProfileGateway, perksEvents: any PerksEventTrackingService) {
        self.gateway = gateway
        self.perksEvents = perksEvents
    }
    
    func fetchScreen(mode: ProfileViewMode) async throws -> ProfileMainScreenModel {
        let response = try await gateway.fetchMainProfile(mode: mode)
        
        let isOwnProfile: Bool
        switch mode {
        case .myProfile:
            isOwnProfile = true
        case .otherUserProfile:
            isOwnProfile = false
        }
        
        return ProfileMainScreenModel(
            header: ProfileHeaderModel(
                userID: response.user_id,
                fullName: response.name,
                username: "@\(response.username)",
                status: response.status,
                subtitle: response.subtitle,
                avatarSystemName: response.avatar_system_name,
                badge: response.badge
            ),
            actions: isOwnProfile
            ? [
                .init(id: "edit_profile", title: String(localized: "profile.action.edit_profile", bundle: .module), iconSystemName: "square.and.pencil", kind: .editProfile),
                .init(id: "settings", title: String(localized: "profile.action.settings", bundle: .module), iconSystemName: "gearshape.fill", kind: .settings),
                .init(id: "posts", title: String(localized: "profile.action.posts", bundle: .module), iconSystemName: "square.grid.2x2.fill", kind: .posts),
                .init(id: "friends", title: String(localized: "profile.action.friends", bundle: .module), iconSystemName: "person.2.fill", kind: .friends),
                .init(id: "calendar", title: String(localized: "profile.action.workout_calendar", bundle: .module), iconSystemName: "calendar", kind: .workoutCalendar),
                .init(id: "statistics", title: String(localized: "profile.action.statistics", bundle: .module), iconSystemName: "chart.bar.fill", kind: .statistics),
                .init(id: "logout", title: String(localized: "profile.action.logout", bundle: .module), iconSystemName: "rectangle.portrait.and.arrow.right", kind: .logout)
            ]
            : [
                .init(id: "friends", title: String(localized: "profile.action.friends", bundle: .module), iconSystemName: "person.2.fill", kind: .friends),
                .init(id: "calendar", title: String(localized: "profile.action.workout_calendar", bundle: .module), iconSystemName: "calendar", kind: .workoutCalendar),
                .init(id: "statistics", title: String(localized: "profile.action.statistics", bundle: .module), iconSystemName: "chart.bar.fill", kind: .statistics)
            ],
            statsPreview: ProfileStatsPreviewModel(
                workoutsThisMonth: response.workouts_this_month,
                totalWorkouts: response.total_workouts,
                totalHours: response.total_hours,
                favoriteWorkoutType: response.favorite_workout_type,
                mostActiveWeekday: response.most_active_weekday,
                consistencyPercent: response.consistency_percent
            ),
            about: ProfileAboutModel(
                bio: response.bio
            ),
            quickInsights: [],
            weeklyActivity: response.weekly_activity.map {
                ProfileWeeklyActivityItem(
                    id: $0.id,
                    dayTitle: $0.day_title,
                    value: $0.value,
                    maxValue: $0.max_value
                )
            },
            relationshipState: isOwnProfile
            ? nil
            : ((response.is_following ?? false) ? .following : .notFollowing)
        )
    }
    
    func createDirectChat(with personID: String) async throws -> ChatSessionInput {
        try await gateway.createDirectChat(with: personID)
    }
    
    func toggleFollow(for userID: Int, isFollowing: Bool) async throws {
        try await gateway.toggleFollow(userID: userID, isFollowing: isFollowing)
    }
    
    func trackProfileOpened(mode: ProfileViewMode) async {
        guard case .otherUserProfile(let userID) = mode else { return }
        await perksEvents.trackProfileOpened(userId: "\(userID)")
    }
    
    private let gateway: any ProfileGateway
    private let perksEvents: any PerksEventTrackingService
}

import Foundation
import GymbroTypes

enum ProfileMainMocks {
    
    static let ownProfile = ProfileMainScreenModel(
        header: ProfileHeaderModel(
            userID: 1,
            fullName: "Alexandra Gritsaenko",
            username: "@alexfit",
            status: "Back in the gym era",
            subtitle: "Strength training • 4x week",
            avatarSystemName: "person.crop.circle.fill",
            badge: "Pro Member"
        ),
        actions: [
            ProfileActionModel(id: "edit", title: "Edit Profile", iconSystemName: "pencil", kind: .editProfile),
            ProfileActionModel(id: "settings", title: "Settings", iconSystemName: "gearshape", kind: .settings),
            ProfileActionModel(id: "friends", title: "Friends", iconSystemName: "person.2", kind: .friends),
            ProfileActionModel(id: "calendar", title: "Workout Calendar", iconSystemName: "calendar", kind: .workoutCalendar),
            ProfileActionModel(id: "statistics", title: "Statistics", iconSystemName: "chart.bar", kind: .statistics),
            ProfileActionModel(id: "logout", title: "Log out", iconSystemName: "rectangle.portrait.and.arrow.right", kind: .logout)
        ],
        statsPreview: ProfileStatsPreviewModel(
            workoutsThisMonth: 14,
            totalWorkouts: 128,
            totalHours: 96,
            favoriteWorkoutType: "Upper Body",
            mostActiveWeekday: "Monday",
            consistencyPercent: 82
        ),
        about: ProfileAboutModel(
            bio: "Training for strength, discipline, and feeling good every week."
        ),
        quickInsights: [
            ProfileQuickInsightModel(id: "insight_1", title: "Last Workout", value: "2 days ago"),
            ProfileQuickInsightModel(id: "insight_2", title: "Favorite Time", value: "Evening"),
            ProfileQuickInsightModel(id: "insight_3", title: "Top Muscle Group", value: "Back")
        ],
        weeklyActivity: [
            ProfileWeeklyActivityItem(id: "mon", dayTitle: "M", value: 3, maxValue: 4),
            ProfileWeeklyActivityItem(id: "tue", dayTitle: "T", value: 1, maxValue: 4),
            ProfileWeeklyActivityItem(id: "wed", dayTitle: "W", value: 4, maxValue: 4),
            ProfileWeeklyActivityItem(id: "thu", dayTitle: "T", value: 2, maxValue: 4),
            ProfileWeeklyActivityItem(id: "fri", dayTitle: "F", value: 3, maxValue: 4),
            ProfileWeeklyActivityItem(id: "sat", dayTitle: "S", value: 2, maxValue: 4),
            ProfileWeeklyActivityItem(id: "sun", dayTitle: "S", value: 0, maxValue: 4)
        ],
        relationshipState: nil
    )
    
    static let otherProfile = ProfileMainScreenModel(
        header: ProfileHeaderModel(
            userID: 2,
            fullName: "Chris Miller",
            username: "@chrismoves",
            status: "Chasing consistency",
            subtitle: "Hybrid training • Running + Gym",
            avatarSystemName: "person.crop.circle.fill",
            badge: "Athlete"
        ),
        actions: [
            ProfileActionModel(id: "friends", title: "Friends", iconSystemName: "person.2", kind: .friends),
            ProfileActionModel(id: "calendar", title: "Workout Calendar", iconSystemName: "calendar", kind: .workoutCalendar),
            ProfileActionModel(id: "statistics", title: "Statistics", iconSystemName: "chart.bar", kind: .statistics)
        ],
        statsPreview: ProfileStatsPreviewModel(
            workoutsThisMonth: 9,
            totalWorkouts: 76,
            totalHours: 51,
            favoriteWorkoutType: "Full Body",
            mostActiveWeekday: "Thursday",
            consistencyPercent: 71
        ),
        about: ProfileAboutModel(
            bio: "Trying to stay active and build a routine that actually lasts."
        ),
        quickInsights: [
            ProfileQuickInsightModel(id: "insight_1", title: "Last Workout", value: "Yesterday"),
            ProfileQuickInsightModel(id: "insight_2", title: "Favorite Time", value: "Morning"),
            ProfileQuickInsightModel(id: "insight_3", title: "Top Muscle Group", value: "Legs")
        ],
        weeklyActivity: [
            ProfileWeeklyActivityItem(id: "mon", dayTitle: "M", value: 1, maxValue: 4),
            ProfileWeeklyActivityItem(id: "tue", dayTitle: "T", value: 2, maxValue: 4),
            ProfileWeeklyActivityItem(id: "wed", dayTitle: "W", value: 0, maxValue: 4),
            ProfileWeeklyActivityItem(id: "thu", dayTitle: "T", value: 3, maxValue: 4),
            ProfileWeeklyActivityItem(id: "fri", dayTitle: "F", value: 2, maxValue: 4),
            ProfileWeeklyActivityItem(id: "sat", dayTitle: "S", value: 1, maxValue: 4),
            ProfileWeeklyActivityItem(id: "sun", dayTitle: "S", value: 2, maxValue: 4)
        ],
        relationshipState: .following
    )
}

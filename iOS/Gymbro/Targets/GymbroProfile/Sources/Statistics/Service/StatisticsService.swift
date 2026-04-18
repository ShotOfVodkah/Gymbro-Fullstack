import Foundation
import GymbroNetwork
import GymbroTypes

protocol ProfileStatisticsServiceProtocol {
    func fetchStatistics(mode: ProfileViewMode) async throws -> ProfileStatisticsScreenModel
}

final class ProfileStatisticsService: ProfileStatisticsServiceProtocol {
    
    init(client: ProfileClient) {
        self.client = client
    }
    
    func fetchStatistics(mode: ProfileViewMode) async throws -> ProfileStatisticsScreenModel {
        let response: ProfileStatisticsResponse
        
        switch mode {
        case .myProfile:
            response = try await client.fetchMyStatistics()
            
        case .otherUserProfile(let userID):
            response = try await client.fetchStatistics(userID: userID)
        }
        
        return ProfileStatisticsScreenModel(
            userID: response.user_id,
            summary: StatisticsSummaryModel(
                totalWorkouts: response.summary.total_workouts,
                totalDurationHours: response.summary.total_duration_hours,
                consistency: response.summary.consistency,
                workoutsThisWeek: response.summary.workouts_this_week,
                workoutsThisMonth: response.summary.workouts_this_month,
                averageWorkoutDurationMinutes: response.summary.average_workout_duration_minutes,
                completionRate: response.summary.completion_rate,
                favoriteMuscleGroup: response.summary.favorite_muscle_group,
                mostActiveDay: response.summary.most_active_day
            ),
            weeklyActivity: response.weekly_activity.map {
                StatisticsBarItem(
                    id: $0.id,
                    label: $0.label,
                    value: $0.value
                )
            },
            monthlyTrend: response.monthly_trend.map {
                StatisticsPointItem(
                    id: $0.id,
                    label: $0.label,
                    value: $0.value
                )
            },
            workoutsByMonth: response.workouts_by_month.map {
                StatisticsMonthCountItem(
                    id: $0.id,
                    monthLabel: $0.month_label,
                    value: $0.value
                )
            },
            categories: response.categories.map {
                StatisticsCategoryItem(
                    id: $0.id,
                    title: $0.title,
                    value: $0.value
                )
            }
        )
    }
    
    private let client: ProfileClient
}

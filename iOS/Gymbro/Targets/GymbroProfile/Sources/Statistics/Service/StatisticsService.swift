import Foundation
import GymbroTypes

protocol ProfileStatisticsServiceProtocol {
    func fetchStatistics(mode: ProfileViewMode) async throws -> ProfileStatisticsScreenModel
}

final class ProfileStatisticsService: ProfileStatisticsServiceProtocol {
    
    func fetchStatistics(mode: ProfileViewMode) async throws -> ProfileStatisticsScreenModel {
        try await Task.sleep(nanoseconds: 600_000_000)
        
        return ProfileStatisticsScreenModel(
            userID: {
                if case let .otherUserProfile(id) = mode { return id }
                return nil
            }(),
            
            summary: .init(
                totalWorkouts: 128,
                totalDurationHours: 96,
                consistency: 82,
                workoutsThisWeek: 4,
                workoutsThisMonth: 14,
                averageWorkoutDurationMinutes: 52,
                completionRate: 88,
                favoriteMuscleGroup: "Legs",
                mostActiveDay: "Friday"
            ),
            
            weeklyActivity: [
                .init(id: "1", label: "M", value: 2),
                .init(id: "2", label: "T", value: 1),
                .init(id: "3", label: "W", value: 3),
                .init(id: "4", label: "T", value: 0),
                .init(id: "5", label: "F", value: 2),
                .init(id: "6", label: "S", value: 1),
                .init(id: "7", label: "S", value: 2)
            ],
            
            monthlyTrend: [
                .init(id: "1", label: "W1", value: 5),
                .init(id: "2", label: "W2", value: 8),
                .init(id: "3", label: "W3", value: 6),
                .init(id: "4", label: "W4", value: 10)
            ],
            
            workoutsByMonth: [
                .init(id: "jan", monthLabel: "Jan", value: 10),
                .init(id: "feb", monthLabel: "Feb", value: 8),
                .init(id: "mar", monthLabel: "Mar", value: 12),
                .init(id: "apr", monthLabel: "Apr", value: 14),
                .init(id: "may", monthLabel: "May", value: 11),
                .init(id: "jun", monthLabel: "Jun", value: 15)
            ],
            
            categories: [
                .init(id: "1", title: "Chest", value: 32),
                .init(id: "2", title: "Back", value: 28),
                .init(id: "3", title: "Legs", value: 40)
            ]
        )
    }
}

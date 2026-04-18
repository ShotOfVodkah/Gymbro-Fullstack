import SwiftUI
import GymbroTypes

struct StatisticsHeroSection: View {
    
    init(summary: StatisticsSummaryModel) {
        self.summary = summary
    }
    
    var body: some View {
        VStack(spacing: 12) {
            StatisticsSummaryCard(
                title: "Total Workouts",
                value: summary.totalWorkouts,
                subtitle: "All recorded training sessions",
                iconSystemName: "figure.strengthtraining.traditional"
            )
            
            HStack(spacing: 12) {
                StatisticsSummaryCard(
                    title: "Total Duration",
                    value: summary.totalDurationHours,
                    suffix: "h",
                    subtitle: "Hours spent training",
                    iconSystemName: "clock.fill"
                )
                .frame(maxWidth: .infinity)
                
                StatisticsSummaryCard(
                    title: "Consistency",
                    value: summary.consistency,
                    suffix: "%",
                    subtitle: "Training rhythm stability",
                    iconSystemName: "bolt.fill"
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private let summary: StatisticsSummaryModel
}

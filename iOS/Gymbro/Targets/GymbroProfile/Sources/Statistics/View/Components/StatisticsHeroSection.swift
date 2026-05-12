import Foundation
import SwiftUI
import GymbroTypes

struct StatisticsHeroSection: View {
    
    init(summary: StatisticsSummaryModel) {
        self.summary = summary
    }
    
    var body: some View {
        VStack(spacing: 12) {
            StatisticsSummaryCard(
                title: String(localized: "statistics.hero.total_workouts", bundle: .module),
                value: summary.totalWorkouts,
                subtitle: String(localized: "statistics.hero.total_workouts_sub", bundle: .module),
                iconSystemName: "figure.strengthtraining.traditional"
            )
            
            HStack(spacing: 12) {
                StatisticsSummaryCard(
                    title: String(localized: "statistics.hero.total_duration", bundle: .module),
                    value: summary.totalDurationHours,
                    suffix: "h",
                    subtitle: String(localized: "statistics.hero.total_duration_sub", bundle: .module),
                    iconSystemName: "clock.fill"
                )
                .frame(maxWidth: .infinity)
                
                StatisticsSummaryCard(
                    title: String(localized: "statistics.hero.consistency", bundle: .module),
                    value: summary.consistency,
                    suffix: "%",
                    subtitle: String(localized: "statistics.hero.consistency_sub", bundle: .module),
                    iconSystemName: "bolt.fill"
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private let summary: StatisticsSummaryModel
}

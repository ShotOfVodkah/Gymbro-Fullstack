import SwiftUI

@testable import GymbroProfile

enum StatisticsSummaryCardSnapshotExamples {
    static let snapshotSize = CGSize(width: 240, height: 140)

    static let snapshotExamples: [StatisticsSummaryCardSnapshotCase] = [
        StatisticsSummaryCardSnapshotCase(
            name: "default",
            makeView: {
                StatisticsSummaryCard(
                    title: "Total workouts",
                    value: 128,
                    iconSystemName: "figure.strengthtraining.traditional"
                )
            }
        ),
        StatisticsSummaryCardSnapshotCase(
            name: "with_suffix_and_subtitle",
            makeView: {
                StatisticsSummaryCard(
                    title: "Average session",
                    value: 52,
                    suffix: " min",
                    subtitle: "Compared to last month",
                    iconSystemName: "clock.fill"
                )
            }
        )
    ]
}

struct StatisticsSummaryCardSnapshotCase {
    let name: String
    let makeView: () -> StatisticsSummaryCard
}

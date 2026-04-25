import SwiftUI

@testable import GymbroProfile

enum ProfileStatChipViewSnapshotExamples {
    static let snapshotSize = CGSize(width: 170, height: 80)

    static let snapshotExamples: [ProfileStatChipSnapshotCase] = [
        ProfileStatChipSnapshotCase(
            name: "short",
            makeView: {
                ProfileStatChipView(
                    title: "Workouts",
                    value: "48"
                )
            }
        ),
        ProfileStatChipSnapshotCase(
            name: "long_title",
            makeView: {
                ProfileStatChipView(
                    title: "Consistency this month",
                    value: "92%"
                )
            }
        )
    ]
}

struct ProfileStatChipSnapshotCase {
    let name: String
    let makeView: () -> ProfileStatChipView
}

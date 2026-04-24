import GymbroTypes
import SwiftUI

@testable import GymbroWorkouts

enum WorkoutGeneratorInjuryToggleSnapshotExamples {
    static let snapshotSize = CGSize(width: 200, height: 100)

    static let snapshotExamples: [InjuryToggleChipSnapshotCase] = [
        InjuryToggleChipSnapshotCase(
            name: "label_deselected",
            makeView: {
                InjuryToggleChip(
                    label: "Some text",
                    isSelected: false,
                    action: {}
                )
            }
        ),
        InjuryToggleChipSnapshotCase(
            name: "label_selected",
            makeView: {
                InjuryToggleChip(
                    label: "Some text",
                    isSelected: true,
                    action: {}
                )
            }
        ),
        InjuryToggleChipSnapshotCase(
            name: "long_label_deselected",
            makeView: {
                InjuryToggleChip(
                    label: "Some very very very very longtext",
                    isSelected: false,
                    action: {}
                )
            }
        ),
        InjuryToggleChipSnapshotCase(
            name: "long_label_selected",
            makeView: {
                InjuryToggleChip(
                    label: "Some very very very very longtext",
                    isSelected: true,
                    action: {}
                )
            }
        )
    ]
}

struct InjuryToggleChipSnapshotCase {
    let name: String
    let makeView: () -> InjuryToggleChip
}

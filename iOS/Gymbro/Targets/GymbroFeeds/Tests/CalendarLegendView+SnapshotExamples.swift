import SwiftUI

@testable import GymbroFeeds

enum CalendarLegendViewSnapshotExamples {
    static let snapshotSize = CGSize(width: 520, height: 48)

    static let snapshotExamples: [CalendarLegendSnapshotCase] = [
        CalendarLegendSnapshotCase(
            name: "default",
            makeView: { CalendarLegendView() }
        )
    ]
}

struct CalendarLegendSnapshotCase {
    let name: String
    let makeView: () -> CalendarLegendView
}

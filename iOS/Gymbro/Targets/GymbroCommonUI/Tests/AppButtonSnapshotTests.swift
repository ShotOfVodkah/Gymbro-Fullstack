import GymbroCommonUI
import SwiftUI
import XCTest

final class AppButtonSnapshotTests: XCTestCase {

    func test_snapshots() {
        for example in AppButtonSnapshotExamples.all {
            CommonUISnapshotTestHelpers.assertHostingSnapshot(
                of: example.view,
                named: example.name,
                size: AppButtonSnapshotExamples.containerSize
            )
        }
    }
}

private enum AppButtonSnapshotExamples {
    static let containerSize = CGSize(width: 360, height: 120)

    private static func centered<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack {
            Spacer(minLength: 0)
            HStack {
                Spacer(minLength: 0)
                content()
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    static var all: [(name: String, view: AnyView)] {
        [
            (
                "text_xl",
                AnyView(centered { AppButton("Continue", size: .xl) {} })
            ),
            (
                "text_l",
                AnyView(centered { AppButton("OK", size: .l) {} })
            ),
            (
                "text_m",
                AnyView(centered { AppButton("Save", size: .m) {} })
            ),
            (
                "icon_l",
                AnyView(centered { AppButton(systemImage: "play.fill", size: .l) {} })
            )
        ]
    }
}

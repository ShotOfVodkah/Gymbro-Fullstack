import GymbroCommonUI
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

enum CommonUISnapshotTestHelpers {
    static func assertHostingSnapshot<Content: View>(
        of view: @autoclosure () -> Content,
        named name: String,
        record: SnapshotTestingConfiguration.Record? = .never,
        size: CGSize,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let traits = UITraitCollection(traitsFrom: [
            UITraitCollection(horizontalSizeClass: .compact),
            UITraitCollection(verticalSizeClass: .regular),
            UITraitCollection(userInterfaceStyle: .light)
        ])

        let root = view()
            .environment(\.locale, Locale(identifier: "en_US"))
            .environment(\.colorScheme, .light)
            .transaction { $0.animation = nil }

        let host = UIHostingController(rootView: root)
        host.view.bounds = CGRect(origin: .zero, size: size)
        host.view.backgroundColor = .clear
        host.view.layer.speed = 0
        host.view.layoutIfNeeded()

        assertSnapshot(
            of: host,
            as: .image(
                precision: 0.88,
                perceptualPrecision: 0.80,
                size: size,
                traits: traits
            ),
            named: name,
            record: record,
            file: file,
            testName: testName,
            line: line
        )
    }
}

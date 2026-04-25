import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@testable import GymbroProfile

final class SettingsRowSnapshotTests: XCTestCase {

    func test_snapshots() {
        for example in SettingsRowSnapshotExamples.snapshotExamples {
            assertSettingsRow(
                name: example.name,
                makeView: example.makeView
            )
        }
    }
}

private func assertSettingsRow(
    name: String,
    makeView: @escaping () -> SettingsRow,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {
    let size = SettingsRowSnapshotExamples.snapshotSize
    let traits = UITraitCollection(traitsFrom: [
        UITraitCollection(horizontalSizeClass: .compact),
        UITraitCollection(verticalSizeClass: .regular),
        UITraitCollection(userInterfaceStyle: .light)
    ])

    let root = makeView()
        .environment(\.locale, Locale(identifier: "en_US"))
        .environment(\.colorScheme, .light)
        .transaction { $0.animation = nil }

    let host = UIHostingController(rootView: root)
    host.view.bounds = CGRect(origin: .zero, size: size)
    host.view.backgroundColor = .black
    host.view.layer.speed = 0
    host.view.layoutIfNeeded()

    assertSnapshot(
        of: host,
        as: .image(
            precision: 0.98,
            perceptualPrecision: 0.99,
            size: size,
            traits: traits
        ),
        named: name,
        file: file,
        testName: testName,
        line: line
    )
}

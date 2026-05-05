import XCTest

final class SmokeUITests: BaseUITestCase {

    func testAppLaunchesInAuthorizedMode() {
        launchApp()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }
}

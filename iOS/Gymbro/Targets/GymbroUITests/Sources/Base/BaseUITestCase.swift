import XCTest

class BaseUITestCase: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func launchApp(
        configuration: AppLaunchConfiguration = AppLaunchConfiguration()
    ) {
        app = XCUIApplication()
        app.launchArguments = configuration.launchArguments
        app.launch()
    }
}

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

    func element(_ id: String) -> XCUIElement {
        app.descendants(matching: .any)[id]
    }

    func assertExists(
        _ id: String,
        timeout: TimeInterval = 8,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let element = element(id)

        XCTAssertTrue(
            element.waitForExistence(timeout: timeout),
            "Expected element to exist: \(id)",
            file: file,
            line: line
        )
    }
    
    func assertElementExists(
        _ element: XCUIElement,
        timeout: TimeInterval = 8,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            element.waitForExistence(timeout: timeout),
            "Expected element to exist: \(element)",
            file: file,
            line: line
        )
    }
}

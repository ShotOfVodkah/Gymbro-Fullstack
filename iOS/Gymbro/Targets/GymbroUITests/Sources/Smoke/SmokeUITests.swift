import XCTest

final class SmokeUITests: BaseUITestCase {

    func testAppLaunches() {
        launchApp()

        XCTAssertEqual(app.state, .runningForeground)
    }

    func testShowsAuthScreenWithoutAuthorizedUser() {
        launchApp(
            configuration: AppLaunchConfiguration(
                resetState: true,
                mockNetwork: true,
                authorizedUser: false
            )
        )

        assertExists(TestIDs.Auth.screen)
    }

    func testShowsMainAppWithAuthorizedUser() {
        launchApp(
            configuration: AppLaunchConfiguration(
                resetState: true,
                mockNetwork: true,
                authorizedUser: true
            )
        )

        assertExists(TestIDs.App.mainContent)
        assertExists(TestIDs.Screen.workouts)
    }

    func testUsesMockNetworkInUITestingMode() {
        launchApp()

        assertExists(TestIDs.Debug.mockNetwork)
        XCTAssertFalse(element(TestIDs.Debug.realNetwork).exists)
    }
}

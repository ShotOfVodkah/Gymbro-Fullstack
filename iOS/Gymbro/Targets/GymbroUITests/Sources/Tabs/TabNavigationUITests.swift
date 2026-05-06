import XCTest

final class TabNavigationUITests: BaseUITestCase {

    func testUserCanOpenAllMainTabs() {
        launchApp()

        assertExists(TestIDs.Screen.workouts)

        element(TestIDs.Tab.feeds).tap()
        assertExists(TestIDs.Screen.feeds)

        element(TestIDs.Tab.profile).tap()
        assertExists(TestIDs.Screen.profile)

        element(TestIDs.Tab.challenge).tap()
        assertExists(TestIDs.Screen.challenges)

        element(TestIDs.Tab.perks).tap()
        assertExists(TestIDs.Screen.perks)

        element(TestIDs.Tab.workouts).tap()
        assertExists(TestIDs.Screen.workouts)
    }
}

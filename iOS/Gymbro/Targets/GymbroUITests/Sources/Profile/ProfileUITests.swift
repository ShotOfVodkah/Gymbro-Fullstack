import XCTest

final class ProfileUITests: BaseUITestCase {

    private let uiTestPostID = "feed_post_ui_1"

    private func openMyProfileLoaded() {
        launchApp()
        element(TestIDs.Tab.profile).tap()
        assertExists(TestIDs.Screen.profile)
        assertExists(TestIDs.Profile.myLoaded)
    }

    private func tapNavigationBack() {
        let navBar = app.navigationBars.element(boundBy: 0)
        XCTAssertTrue(navBar.waitForExistence(timeout: 8))
        let backButton = navBar.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 8))
        backButton.tap()
    }

    private func scrollFirstScrollViewUpUntilHittable(button: XCUIElement, maxSwipes: Int = 10) {
        let scroll = app.scrollViews.element(boundBy: 0)
        XCTAssertTrue(scroll.waitForExistence(timeout: 6))
        var attempts = 0
        while !button.isHittable && attempts < maxSwipes {
            scroll.swipeUp()
            attempts += 1
        }
    }

    func testOpenMyProfile() {
        openMyProfileLoaded()
        XCTAssertTrue(app.staticTexts["UI Test User"].waitForExistence(timeout: 8))
    }

    func testOpenOtherUserProfileFromFeed() {
        launchApp()
        element(TestIDs.Tab.feeds).tap()
        assertExists(TestIDs.Feeds.contentLoaded)

        app.buttons[TestIDs.Feeds.postAuthor(uiTestPostID)].tap()

        assertExists(TestIDs.Profile.otherUserScreen)
        XCTAssertTrue(app.staticTexts["Kylie Stone"].waitForExistence(timeout: 8))
    }

    func testNavigateToEditProfile() {
        openMyProfileLoaded()
        app.buttons[TestIDs.Profile.actionEditProfile].tap()
        assertExists(TestIDs.Profile.editScreen)
    }

    func testEditProfileChangeNameStatusBioAndSave() {
        openMyProfileLoaded()
        app.buttons[TestIDs.Profile.actionEditProfile].tap()
        assertExists(TestIDs.Profile.editScreen)

        let nameField = app.textFields[TestIDs.Profile.editFullName]
        XCTAssertTrue(nameField.waitForExistence(timeout: 8))
        nameField.tap()
        nameField.typeText(".")

        let statusField = app.textFields[TestIDs.Profile.editStatus]
        XCTAssertTrue(statusField.waitForExistence(timeout: 8))
        statusField.tap()
        statusField.typeText("!")

        let bioField = app.textViews[TestIDs.Profile.editBio]
        XCTAssertTrue(bioField.waitForExistence(timeout: 8))
        bioField.tap()
        bioField.typeText(" UITest")

        app.buttons[TestIDs.Profile.editSave].tap()

        XCTAssertTrue(element(TestIDs.Profile.myLoaded).waitForExistence(timeout: 15))
    }

    func testNavigateToStatisticsAndBack() {
        openMyProfileLoaded()
        app.buttons[TestIDs.Profile.actionStatistics].tap()
        assertExists(TestIDs.Profile.statisticsScreen)
        XCTAssertTrue(app.staticTexts["My Statistics"].waitForExistence(timeout: 8))

        tapNavigationBack()
        assertExists(TestIDs.Profile.myLoaded)
    }

    func testStatisticsFromOtherUserProfile() {
        launchApp()
        element(TestIDs.Tab.feeds).tap()
        assertExists(TestIDs.Feeds.contentLoaded)

        app.buttons[TestIDs.Feeds.postAuthor(uiTestPostID)].tap()
        assertExists(TestIDs.Profile.otherUserScreen)

        app.buttons[TestIDs.Profile.actionStatistics].tap()
        assertExists(TestIDs.Profile.statisticsScreen)
        XCTAssertTrue(app.staticTexts["User Statistics"].waitForExistence(timeout: 8))
    }

    func testNavigateToSettingsAndBack() {
        openMyProfileLoaded()
        app.buttons[TestIDs.Profile.settingsButton].tap()
        assertExists(TestIDs.Profile.settingsScreen)

        tapNavigationBack()
        assertExists(TestIDs.Profile.myLoaded)
    }

    func testLogoutFromSettings() {
        openMyProfileLoaded()
        app.buttons[TestIDs.Profile.settingsButton].tap()
        assertExists(TestIDs.Profile.settingsScreen)

        let logout = app.buttons[TestIDs.Settings.logoutButton]
        scrollFirstScrollViewUpUntilHittable(button: logout)
        XCTAssertTrue(logout.waitForExistence(timeout: 4))
        logout.tap()

        assertExists(TestIDs.Auth.screen)
    }

    func testLogoutFromProfilePrimaryActions() {
        openMyProfileLoaded()

        let logout = app.buttons[TestIDs.Profile.actionLogout]
        scrollFirstScrollViewUpUntilHittable(button: logout)
        XCTAssertTrue(logout.waitForExistence(timeout: 4))
        logout.tap()

        assertExists(TestIDs.Auth.screen)
    }
}

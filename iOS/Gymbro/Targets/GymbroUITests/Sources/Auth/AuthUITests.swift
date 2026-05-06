import XCTest

final class AuthUITests: BaseUITestCase {

    // MARK: - Login / main app

    func testLoginSuccessOpensWorkoutsTab() {
        launchUnauthorizedApp()
        acceptAllLegalDocumentsIfNeeded()

        enterCredentials(
            email: "ui-test@gymbro.dev",
            password: "password123"
        )

        app.buttons[TestIDs.Auth.loginButton].tap()

        assertExists(TestIDs.App.mainContent)
        assertExists(TestIDs.Screen.workouts)
    }

    func testAfterLoginOpensMainApp() {
        launchUnauthorizedApp()
        acceptAllLegalDocumentsIfNeeded()

        enterCredentials(
            email: "ui-test@gymbro.dev",
            password: "password123"
        )

        app.buttons[TestIDs.Auth.loginButton].tap()

        assertExists(TestIDs.App.mainContent)
        XCTAssertTrue(element(TestIDs.Tab.workouts).waitForExistence(timeout: 8))
    }

    func testLoginValidationErrorKeepsUserOnAuthScreen() {
        launchUnauthorizedApp()
        acceptAllLegalDocumentsIfNeeded()

        enterCredentials(
            email: "wrong-email-format",
            password: "password123"
        )

        app.buttons[TestIDs.Auth.loginButton].tap()

        assertValidationAlertPresent()
        dismissAuthAlertIfNeeded()

        assertExists(TestIDs.Auth.screen)
        XCTAssertFalse(element(TestIDs.App.mainContent).exists)
    }

    func testEmptyEmailShowsValidationAndKeepsUserOnAuthScreen() {
        launchUnauthorizedApp()
        acceptAllLegalDocumentsIfNeeded()

        let passwordField = app.secureTextFields[TestIDs.Auth.passwordSecureField]
        assertElementExists(passwordField)
        passwordField.tap()
        passwordField.typeText("password123")

        app.buttons[TestIDs.Auth.loginButton].tap()

        assertAlertStaticTextMatchesAnySubstring([
            "Enter your email address.",
            "Введите адрес email.",
        ])
        dismissAuthAlertIfNeeded()

        assertExists(TestIDs.Auth.screen)
        XCTAssertFalse(element(TestIDs.App.mainContent).exists)
    }

    func testShortPasswordShowsValidationOnRegister() {
        launchUnauthorizedApp()
        acceptAllLegalDocumentsIfNeeded()

        app.buttons[TestIDs.Auth.registerSegment].tap()

        enterCredentials(
            email: "athlete@gymbro.dev",
            password: "Short1"
        )

        app.buttons[TestIDs.Auth.registerButton].tap()

        assertAlertStaticTextMatchesAnySubstring([
            "Password must be at least 8 characters.",
            "Пароль должен быть не короче 8 символов.",
        ])
        dismissAuthAlertIfNeeded()

        assertExists(TestIDs.Auth.screen)
        XCTAssertFalse(element(TestIDs.App.mainContent).exists)
    }

    // MARK: - Register

    func testRegisterAthleteShowsCheckEmailScreen() {
        launchUnauthorizedApp()
        acceptAllLegalDocumentsIfNeeded()

        app.buttons[TestIDs.Auth.registerSegment].tap()
        assertExists(TestIDs.Auth.athleteRole)

        app.buttons[TestIDs.Auth.athleteRole].tap()

        enterCredentials(
            email: "athlete@gymbro.dev",
            password: "Password123"
        )

        app.buttons[TestIDs.Auth.registerButton].tap()

        assertExists(TestIDs.Auth.checkEmailScreen)
    }

    func testRegisterCoachShowsCheckEmailScreen() {
        launchUnauthorizedApp()
        acceptAllLegalDocumentsIfNeeded()

        app.buttons[TestIDs.Auth.registerSegment].tap()
        assertExists(TestIDs.Auth.coachRole)

        app.buttons[TestIDs.Auth.coachRole].tap()

        enterCredentials(
            email: "coach@gymbro.dev",
            password: "Password123"
        )

        app.buttons[TestIDs.Auth.registerButton].tap()

        assertExists(TestIDs.Auth.checkEmailScreen)
    }

    // MARK: - Logout

//    func testAfterLogoutReturnsToAuthScreen() {
//        launchUnauthorizedApp()
//        acceptAllLegalDocumentsIfNeeded()
//
//        enterCredentials(
//            email: "ui-test@gymbro.dev",
//            password: "password123"
//        )
//
//        app.buttons[TestIDs.Auth.loginButton].tap()
//        assertExists(TestIDs.App.mainContent)
//
//        element(TestIDs.Tab.profile).tap()
//        assertExists(TestIDs.Screen.profile)
//
//        app.buttons[TestIDs.Profile.settingsButton].tap()
//
//        let logout = app.buttons[TestIDs.Settings.logoutButton]
//        scrollFirstScrollViewUpUntilHittable(button: logout)
//        XCTAssertTrue(logout.waitForExistence(timeout: 4))
//        logout.tap()
//
//        assertExists(TestIDs.Auth.screen)
//        XCTAssertFalse(element(TestIDs.App.mainContent).exists)
//    }

    // MARK: - Launch & credentials

    private func launchUnauthorizedApp() {
        launchApp(
            configuration: AppLaunchConfiguration(
                resetState: true,
                mockNetwork: true,
                authorizedUser: false
            )
        )

        assertExists(TestIDs.Auth.screen)
    }

    private func enterCredentials(email: String, password: String) {
        let emailField = app.textFields[TestIDs.Auth.emailTextField]
        assertElementExists(emailField)
        emailField.tap()
        emailField.typeText(email)

        let passwordField = app.secureTextFields[TestIDs.Auth.passwordSecureField]
        assertElementExists(passwordField)
        passwordField.tap()
        passwordField.typeText(password)
        passwordField.typeText("\n")
    }

    private func acceptAllLegalDocumentsIfNeeded() {
        tapFirstExistingButton(labels: [
            "Terms of Service",
            "Условиями использования",
        ])
        tapFirstExistingButton(labels: [
            "I agree",
            "Согласен",
        ])

        tapFirstExistingButton(labels: [
            "Privacy Policy",
            "Политикой конфиденциальности",
        ])
        tapFirstExistingButton(labels: [
            "I agree",
            "Согласен",
        ])
    }

    private func tapFirstExistingButton(labels: [String], timeout: TimeInterval = 8) {
        for label in labels {
            let button = app.buttons[label]
            if button.waitForExistence(timeout: timeout) {
                button.tap()
                return
            }
        }
        XCTFail("Expected one of buttons: \(labels.joined(separator: ", "))")
    }

    private func assertAlertStaticTextMatchesAnySubstring(_ substrings: [String]) {
        let predicateFormat = substrings
            .map { _ in "label CONTAINS[c] %@" }
            .joined(separator: " OR ")
        let args = substrings.map { $0 as CVarArg }
        let predicate = NSPredicate(format: predicateFormat, argumentArray: args)
        let match = app.staticTexts.matching(predicate).firstMatch
        XCTAssertTrue(match.waitForExistence(timeout: 6))
    }

    private func assertValidationAlertPresent() {
        assertAlertStaticTextMatchesAnySubstring([
            "Mock validation failed.",
        ])
    }

    private func dismissAuthAlertIfNeeded() {
        let okEN = app.buttons["OK"]
        if okEN.waitForExistence(timeout: 2) {
            okEN.tap()
            return
        }
        let okRU = app.buttons["ОК"]
        if okRU.waitForExistence(timeout: 2) {
            okRU.tap()
        }
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
}

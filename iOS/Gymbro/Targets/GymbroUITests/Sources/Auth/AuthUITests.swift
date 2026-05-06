//import XCTest
//
//final class AuthUITests: BaseUITestCase {
//
//    func testLoginSuccessOpensMainApp() {
//        launchUnauthorizedApp()
//
//        enterCredentials(
//            email: "ui-test@gymbro.dev",
//            password: "password123"
//        )
//
//        submitAuthForm(fallbackButtonID: TestIDs.Auth.loginButton)
//
//        assertExists(TestIDs.App.mainContent)
//        assertExists(TestIDs.Screen.workouts)
//    }
//
//    func testLoginValidationErrorKeepsUserOnAuthScreen() {
//        launchUnauthorizedApp()
//
//        enterCredentials(
//            email: "wrong-email-format",
//            password: "password123"
//        )
//
//        submitAuthForm(fallbackButtonID: TestIDs.Auth.loginButton)
//
//        assertExists(TestIDs.Auth.screen)
//        XCTAssertFalse(element(TestIDs.App.mainContent).exists)
//    }
//
//    func testEmptyEmailShowsValidationAndKeepsUserOnAuthScreen() {
//        launchUnauthorizedApp()
//
//        let passwordField = app.secureTextFields[TestIDs.Auth.passwordSecureField]
//        assertElementExists(passwordField)
//        passwordField.tap()
//        passwordField.typeText("password123")
//
//        submitAuthForm(fallbackButtonID: TestIDs.Auth.loginButton)
//
//        assertExists(TestIDs.Auth.screen)
//        XCTAssertFalse(element(TestIDs.App.mainContent).exists)
//    }
//
//    func testShortPasswordShowsValidationAndKeepsUserOnAuthScreen() {
//        launchUnauthorizedApp()
//
//        enterCredentials(
//            email: "ui-test@gymbro.dev",
//            password: "123"
//        )
//
//        submitAuthForm(fallbackButtonID: TestIDs.Auth.loginButton)
//
//        assertExists(TestIDs.Auth.screen)
//        XCTAssertFalse(element(TestIDs.App.mainContent).exists)
//    }
//
//    func testRegisterAthleteShowsCheckEmailScreen() {
//        launchUnauthorizedApp()
//
//        app.buttons[TestIDs.Auth.registerSegment].tap()
//        assertExists(TestIDs.Auth.athleteRole)
//
//        app.buttons[TestIDs.Auth.athleteRole].tap()
//
//        enterCredentials(
//            email: "athlete@gymbro.dev",
//            password: "Password123"
//        )
//
//        submitAuthForm(fallbackButtonID: TestIDs.Auth.registerButton)
//
//        assertExists(TestIDs.Auth.checkEmailScreen)
//    }
//
//    func testRegisterCoachShowsCheckEmailScreen() {
//        launchUnauthorizedApp()
//
//        app.buttons[TestIDs.Auth.registerSegment].tap()
//        assertExists(TestIDs.Auth.coachRole)
//
//        app.buttons[TestIDs.Auth.coachRole].tap()
//
//        enterCredentials(
//            email: "coach@gymbro.dev",
//            password: "Password123"
//        )
//
//        submitAuthForm(fallbackButtonID: TestIDs.Auth.registerButton)
//
//        assertExists(TestIDs.Auth.checkEmailScreen)
//    }
//
//    func testAfterLoginLogoutReturnsToAuthScreen() {
//        launchUnauthorizedApp()
//
//        enterCredentials(
//            email: "ui-test@gymbro.dev",
//            password: "password123"
//        )
//
//        submitAuthForm(fallbackButtonID: TestIDs.Auth.loginButton)
//        assertExists(TestIDs.App.mainContent)
//
//        dismissKeyboardIfPresent()
//        element(TestIDs.Tab.profile).tap()
//        assertExists(TestIDs.Screen.profile)
//
//        element(TestIDs.Profile.settingsButton).tap()
//        element(TestIDs.Settings.logoutButton).tap()
//
//        assertExists(TestIDs.Auth.screen)
//        XCTAssertFalse(element(TestIDs.App.mainContent).exists)
//    }
//
//    private func launchUnauthorizedApp() {
//        launchApp(
//            configuration: AppLaunchConfiguration(
//                resetState: true,
//                mockNetwork: true,
//                authorizedUser: false
//            )
//        )
//
//        assertExists(TestIDs.Auth.screen)
//    }
//
//    private func enterCredentials(email: String, password: String) {
//        let emailField = app.textFields[TestIDs.Auth.emailTextField]
//        assertElementExists(emailField)
//        emailField.tap()
//        emailField.typeText(email)
//
//        let passwordField = app.secureTextFields[TestIDs.Auth.passwordSecureField]
//        assertElementExists(passwordField)
//        passwordField.tap()
//        passwordField.typeText(password)
//        passwordField.typeText("\n")
//
//        dismissKeyboardIfPresent()
//    }
//}

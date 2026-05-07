import XCTest

final class WorkoutsUITests: BaseUITestCase {

    private func openWorkoutsTab(configuration: AppLaunchConfiguration = AppLaunchConfiguration()) {
        launchApp(configuration: configuration)
        element(TestIDs.Tab.workouts).tap()
        assertExists(TestIDs.Screen.workouts)
        assertExists(TestIDs.Workouts.listLoaded)
    }

    private func tapDivLabel(_ label: String, timeout: TimeInterval = 12) {
        let text = app.staticTexts[label]
        XCTAssertTrue(text.waitForExistence(timeout: timeout), "Missing Div label: \(label)")
        text.tap()
    }

    private func typeIntoField(identifier: String, text: String) {
        let target = element(identifier)
        XCTAssertTrue(target.waitForExistence(timeout: 8))
        target.tap()
        target.typeText(text)
    }

    // MARK: - Core flow (list → info → player → finish)

    func testWorkoutsListLoads() {
        openWorkoutsTab()
        XCTAssertTrue(app.staticTexts["UITest Workouts"].waitForExistence(timeout: 12))
    }

    func testWorkoutInfoOpensFromList() {
        openWorkoutsTab()
        tapDivLabel("UITest workout • tap for workout info")
        assertExists(TestIDs.Workouts.infoScreen)
        XCTAssertTrue(app.staticTexts["UITest workout detail"].waitForExistence(timeout: 12))
    }

    func testWorkoutPlayerOpensAndFinishSaveOnlyReturnsToList() {
        openWorkoutsTab()
        tapDivLabel("UITest workout • tap for workout info")
        assertExists(TestIDs.Workouts.infoScreen)
        tapDivLabel("▶ Start workout (UITest)")

        assertExists(TestIDs.Workouts.playerLoaded)
        XCTAssertTrue(app.staticTexts["UITest Strength Session"].waitForExistence(timeout: 12))

        XCTAssertTrue(app.buttons[TestIDs.Workouts.playerFinish].waitForExistence(timeout: 12))
        app.buttons[TestIDs.Workouts.playerFinish].tap()

        XCTAssertTrue(app.buttons[TestIDs.Workouts.finishSaveOnly].waitForExistence(timeout: 8))
        app.buttons[TestIDs.Workouts.finishSaveOnly].tap()

        assertExists(TestIDs.Workouts.listLoaded)
    }

    func testWorkoutFinishOpensShareFlow() {
        openWorkoutsTab()
        tapDivLabel("UITest workout • tap for workout info")
        tapDivLabel("▶ Start workout (UITest)")

        XCTAssertTrue(app.buttons[TestIDs.Workouts.playerFinish].waitForExistence(timeout: 12))
        app.buttons[TestIDs.Workouts.playerFinish].tap()

        XCTAssertTrue(app.buttons[TestIDs.Workouts.finishShare].waitForExistence(timeout: 8))
        app.buttons[TestIDs.Workouts.finishShare].tap()

        assertExists(TestIDs.Workouts.shareLoaded)
        let primary = app.buttons[TestIDs.Feeds.workoutSharePrimary]
        XCTAssertTrue(primary.waitForExistence(timeout: 12))
    }

    // MARK: - Builder / generator / create workout

    func testWorkoutBuilderOpensFromList() {
        openWorkoutsTab()
        tapDivLabel("UITest • Open workout builder")
        assertExists(TestIDs.Workouts.builderLoaded)
        XCTAssertTrue(app.staticTexts["UITest Builder"].waitForExistence(timeout: 12))
    }

    func testWorkoutGeneratorOpensFromBuilder() {
        openWorkoutsTab()
        tapDivLabel("UITest • Open workout builder")
        tapDivLabel("UITest • Open AI workout generator")
        assertExists(TestIDs.Workouts.generatorLoaded)
        XCTAssertTrue(element(TestIDs.Workouts.generatorPrompt).waitForExistence(timeout: 12))
    }

    func testWorkoutGeneratorProducesWorkoutAndSaveReturnsToList() {
        openWorkoutsTab()
        tapDivLabel("UITest • Open workout builder")
        tapDivLabel("UITest • Open AI workout generator")

        typeIntoField(identifier: TestIDs.Workouts.generatorPrompt, text: "Leg day focus")

        app.buttons[TestIDs.Workouts.generatorGenerate].tap()

        XCTAssertTrue(app.staticTexts["Generated UITest"].waitForExistence(timeout: 15))
        app.buttons[TestIDs.Workouts.generatorResultSave].tap()

        assertExists(TestIDs.Workouts.listLoaded)
    }

    func testCreateWorkoutInStrengthBuilder() {
        openWorkoutsTab()
        tapDivLabel("UITest • Open workout builder")
        tapDivLabel("UITest • New strength workout")

        assertExists(TestIDs.Workouts.builderForTypeLoaded)

        tapDivLabel("UITest Squat — add")

        typeIntoField(identifier: TestIDs.Workouts.builderName, text: "UITest Created Plan")

        app.buttons[TestIDs.Workouts.builderForTypeSave].tap()

        assertExists(TestIDs.Workouts.listLoaded)
    }

    // MARK: - Offline player

    func testWorkoutPlayerOfflineShowsBanner() {
        var configuration = AppLaunchConfiguration()
        configuration.workoutsPlayerOffline = true
        openWorkoutsTab(configuration: configuration)

        tapDivLabel("UITest workout • tap for workout info")
        tapDivLabel("▶ Start workout (UITest)")

        XCTAssertTrue(element(TestIDs.Workouts.offlineBanner).waitForExistence(timeout: 12))
        assertExists(TestIDs.Workouts.playerLoaded)
    }
}

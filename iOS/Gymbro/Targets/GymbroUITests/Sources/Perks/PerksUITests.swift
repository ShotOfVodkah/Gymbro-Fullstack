import XCTest

final class PerksUITests: BaseUITestCase {

    private func openPerksDashboard(configuration: AppLaunchConfiguration = AppLaunchConfiguration()) {
        launchApp(configuration: configuration)
        element(TestIDs.Tab.perks).tap()
        assertExists(TestIDs.Screen.perks)
        assertExists(TestIDs.Perks.dashboardLoaded)
    }

    private func scrollLeaderboardIntoView(maxSwipes: Int = 18) {
        let title = app.staticTexts["Leaderboard"]
        var swipeCount = 0
        while !title.isHittable && swipeCount < maxSwipes {
            app.swipeUp()
            swipeCount += 1
        }
    }

    // MARK: - Tab & sections

    func testPerksTabOpensAndDashboardLoads() {
        openPerksDashboard()
        assertExists(TestIDs.Perks.streakCard)
    }

    func testStreakCardIsVisible() {
        openPerksDashboard()
        assertExists(TestIDs.Perks.streakCard)
    }

    func testRecentUnlocksSectionVisible() {
        openPerksDashboard()
        assertExists(TestIDs.Perks.recentUnlocksSection)
        XCTAssertTrue(app.staticTexts["Recent Unlocks"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Rookie"].waitForExistence(timeout: 8))
    }

    func testAchievementsSectionVisible() {
        openPerksDashboard()
        assertExists(TestIDs.Perks.achievementsSection)
        XCTAssertTrue(app.staticTexts["Achievements"].waitForExistence(timeout: 8))
    }

    // MARK: - Achievements categories & expanded card

    func testAchievementCategoryFilterSwitch() {
        openPerksDashboard()

        let milestonesChip = app.buttons[TestIDs.Perks.achievementCategory("workoutMilestones")]
        XCTAssertTrue(milestonesChip.waitForExistence(timeout: 8))
        milestonesChip.tap()

        XCTAssertTrue(app.buttons[TestIDs.Perks.achievementCard("rookie")].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons[TestIDs.Perks.achievementCard("workouts_50")].waitForExistence(timeout: 8))

        app.buttons[TestIDs.Perks.achievementCategory("consistency")].tap()
        XCTAssertTrue(app.buttons[TestIDs.Perks.achievementCard("week_warrior")].waitForExistence(timeout: 8))

        app.buttons[TestIDs.Perks.achievementCategory("all")].tap()
        XCTAssertTrue(app.buttons[TestIDs.Perks.achievementCard("rookie")].waitForExistence(timeout: 8))
    }

    func testAchievementExpandedOpenAndClose() {
        openPerksDashboard()

        let rookieCard = app.buttons[TestIDs.Perks.achievementCard("rookie")]
        XCTAssertTrue(rookieCard.waitForExistence(timeout: 8))
        rookieCard.tap()

        assertExists(TestIDs.Perks.achievementExpanded)
        XCTAssertTrue(app.staticTexts["First recorded workout"].waitForExistence(timeout: 8))

        app.buttons[TestIDs.Perks.achievementExpandedClose].tap()

        let expanded = element(TestIDs.Perks.achievementExpanded)
        let dismissed = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: expanded
        )
        wait(for: [dismissed], timeout: 5)
    }

    // MARK: - Leaderboard

    func testLeaderboardSectionAndRows() {
        openPerksDashboard()

        scrollLeaderboardIntoView()
        XCTAssertTrue(app.staticTexts["Leaderboard"].waitForExistence(timeout: 8))
        assertExists(TestIDs.Perks.leaderboardSection)
        assertExists(TestIDs.Perks.leaderboardMyRank)
        XCTAssertTrue(element(TestIDs.Perks.leaderboardRow("leader_1")).waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Kylie Stone"].waitForExistence(timeout: 8))
    }

    func testLeaderboardFilterAndSortChips() {
        openPerksDashboard()

        scrollLeaderboardIntoView()

        app.buttons[TestIDs.Perks.leaderboardFilter("following")].tap()
        XCTAssertTrue(element(TestIDs.Perks.leaderboardRow("leader_1")).waitForExistence(timeout: 8))

        app.buttons[TestIDs.Perks.leaderboardSort("workouts")].tap()
        XCTAssertTrue(element(TestIDs.Perks.leaderboardRow("leader_2")).waitForExistence(timeout: 8))
    }

    // MARK: - Streak visual states (mock variants)

    func testStreakFooterShowsNormalState() {
        openPerksDashboard()
        assertExists(TestIDs.Perks.streakStateNormal)
    }

    func testStreakFooterShowsCompletedState() {
        var configuration = AppLaunchConfiguration()
        configuration.perksStreakVariant = .completed
        openPerksDashboard(configuration: configuration)
        assertExists(TestIDs.Perks.streakStateCompleted)
        XCTAssertTrue(app.staticTexts["Goal completed this week."].waitForExistence(timeout: 8))
    }

    func testStreakFooterShowsFreezeState() {
        var configuration = AppLaunchConfiguration()
        configuration.perksStreakVariant = .freezeActive
        openPerksDashboard(configuration: configuration)
        assertExists(TestIDs.Perks.streakStateFreeze)
        XCTAssertTrue(app.staticTexts["Freezed this week"].waitForExistence(timeout: 8))
    }

    func testStreakFooterShowsDangerState() {
        var configuration = AppLaunchConfiguration()
        configuration.perksStreakVariant = .dangerWindow
        openPerksDashboard(configuration: configuration)
        assertExists(TestIDs.Perks.streakStateDanger)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "still needed")).firstMatch.waitForExistence(timeout: 8))
    }
}

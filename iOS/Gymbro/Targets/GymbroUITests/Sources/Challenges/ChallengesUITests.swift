import XCTest

final class ChallengesUITests: BaseUITestCase {

    private func openChallengesTab(configuration: AppLaunchConfiguration = AppLaunchConfiguration()) {
        launchApp(configuration: configuration)
        element(TestIDs.Tab.challenge).tap()
        assertExists(TestIDs.Screen.challenges)
        assertExists(TestIDs.Challenges.listLoaded)
    }

    private func scrollChallengeDetailsLeaderboardPreviewIntoView(maxSwipes: Int = 28) {
        let viewAll = app.buttons[TestIDs.Challenges.detailsLeaderboardViewAll]
        var swipeCount = 0
        while !viewAll.isHittable && swipeCount < maxSwipes {
            app.swipeUp()
            swipeCount += 1
        }
    }

    private func scrollLeaveChallengeIntoView(maxSwipes: Int = 28) {
        let leave = app.buttons[TestIDs.Challenges.detailsLeave]
        var swipeCount = 0
        while !leave.isHittable && swipeCount < maxSwipes {
            app.swipeUp()
            swipeCount += 1
        }
    }

    func testChallengesTabOpensAndChallengeListShowsCards() {
        openChallengesTab()

        XCTAssertTrue(element(TestIDs.Challenges.card("challenge_power_sprint")).waitForExistence(timeout: 8))
        XCTAssertTrue(element(TestIDs.Challenges.card("challenge_cardio_week")).waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Team Power Sprint"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Cardio Week"].waitForExistence(timeout: 8))
    }

    func testChallengeDetailsOpensFromChallengeCard() {
        openChallengesTab()

        element(TestIDs.Challenges.card("challenge_power_sprint")).tap()

        assertExists(TestIDs.Challenges.detailsLoaded)
        XCTAssertTrue(app.staticTexts["Team Power Sprint"].waitForExistence(timeout: 8))
    }

    func testChallengeLeaderboardOpensFromDetails() {
        openChallengesTab()

        element(TestIDs.Challenges.card("challenge_power_sprint")).tap()
        assertExists(TestIDs.Challenges.detailsLoaded)

        scrollChallengeDetailsLeaderboardPreviewIntoView()
        XCTAssertTrue(app.buttons[TestIDs.Challenges.detailsLeaderboardViewAll].waitForExistence(timeout: 8))
        app.buttons[TestIDs.Challenges.detailsLeaderboardViewAll].tap()

        assertExists(TestIDs.Challenges.leaderboardLoaded)
        XCTAssertTrue(app.staticTexts["Team standings"].waitForExistence(timeout: 8))

        app.buttons[TestIDs.Challenges.leaderboardBack].tap()

        assertExists(TestIDs.Challenges.detailsLoaded)
    }

    func testJoinChallengeSelectTeamConfirmSuccessReturnsToList() {
        openChallengesTab()

        XCTAssertTrue(app.buttons[TestIDs.Challenges.cardJoin("challenge_power_sprint")].waitForExistence(timeout: 8))
        app.buttons[TestIDs.Challenges.cardJoin("challenge_power_sprint")].tap()

        assertExists(TestIDs.Challenges.joinLoaded)
        XCTAssertTrue(app.staticTexts["Pick your squad"].waitForExistence(timeout: 8))

        app.buttons[TestIDs.Challenges.joinTeam("mock_group_chat")].tap()

        XCTAssertTrue(app.buttons[TestIDs.Challenges.joinConfirm].waitForExistence(timeout: 8))
        app.buttons[TestIDs.Challenges.joinConfirm].tap()

        assertExists(TestIDs.Challenges.joinSuccess)
        XCTAssertTrue(app.staticTexts["Team joined"].waitForExistence(timeout: 8))

        app.buttons[TestIDs.Challenges.joinSuccessDone].tap()

        assertExists(TestIDs.Challenges.listLoaded)
        XCTAssertTrue(element(TestIDs.Challenges.card("challenge_power_sprint")).waitForExistence(timeout: 8))
    }

    func testUnavailableTeamShowsReasonAndDoesNotOpenConfirmation() {
        var configuration = AppLaunchConfiguration()
        configuration.challengesUnavailableTeams = true
        openChallengesTab(configuration: configuration)

        app.buttons[TestIDs.Challenges.cardJoin("challenge_power_sprint")].tap()
        assertExists(TestIDs.Challenges.joinLoaded)

        XCTAssertTrue(app.staticTexts["Team is full"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons[TestIDs.Challenges.joinTeam("mock_group_chat")].waitForExistence(timeout: 8))

        app.buttons[TestIDs.Challenges.joinTeam("mock_group_chat")].tap()

        XCTAssertFalse(app.buttons[TestIDs.Challenges.joinConfirm].waitForExistence(timeout: 1))
    }

    func testLeaveChallengeRemovesLeaveButton() {
        openChallengesTab()

        XCTAssertTrue(element(TestIDs.Challenges.card("challenge_cardio_week")).waitForExistence(timeout: 8))
        element(TestIDs.Challenges.card("challenge_cardio_week")).tap()

        assertExists(TestIDs.Challenges.detailsLoaded)
        XCTAssertTrue(app.staticTexts["Cardio Week"].waitForExistence(timeout: 8))

        scrollLeaveChallengeIntoView()
        XCTAssertTrue(app.buttons[TestIDs.Challenges.detailsLeave].waitForExistence(timeout: 8))
        app.buttons[TestIDs.Challenges.detailsLeave].tap()

        let leaveButton = app.buttons[TestIDs.Challenges.detailsLeave]
        let gone = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: leaveButton
        )
        wait(for: [gone], timeout: 12)

        XCTAssertTrue(element(TestIDs.Challenges.detailsLoaded).waitForExistence(timeout: 8))
    }

    func testChallengeFlowListDetailsLeaderboardEndToEnd() {
        openChallengesTab()

        element(TestIDs.Challenges.card("challenge_power_sprint")).tap()
        assertExists(TestIDs.Challenges.detailsLoaded)

        scrollChallengeDetailsLeaderboardPreviewIntoView()
        app.buttons[TestIDs.Challenges.detailsLeaderboardViewAll].tap()
        assertExists(TestIDs.Challenges.leaderboardLoaded)

        app.buttons[TestIDs.Challenges.leaderboardBack].tap()
        assertExists(TestIDs.Challenges.detailsLoaded)

        app.buttons[TestIDs.Challenges.detailsBack].tap()
        assertExists(TestIDs.Challenges.listLoaded)
    }
}

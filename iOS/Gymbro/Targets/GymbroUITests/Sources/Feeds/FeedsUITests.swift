import XCTest

final class FeedsUITests: BaseUITestCase {

    private let uiTestPostID = "feed_post_ui_1"
    private let uiTestDirectCommunityID = "chat_direct_ui"

    private func launchAuthenticatedFeedsTab() {
        launchApp()
        element(TestIDs.Tab.feeds).tap()
        assertExists(TestIDs.Screen.feeds)
        assertExists(TestIDs.Feeds.contentLoaded)
    }

    func testFeedsMainTabOpensAndFeedLoads() {
        launchAuthenticatedFeedsTab()
        XCTAssertTrue(app.buttons[TestIDs.Feeds.postLike(uiTestPostID)].waitForExistence(timeout: 8))
    }

    func testFeedTabSwitching() {
        launchAuthenticatedFeedsTab()

        for raw in ["forYou", "friends", "personal", "group"] {
            element(TestIDs.Feeds.feedTab(raw)).tap()
            assertExists(TestIDs.Feeds.contentLoaded)
        }
    }

    func testLikePost() {
        launchAuthenticatedFeedsTab()

        let like = app.buttons[TestIDs.Feeds.postLike(uiTestPostID)]
        XCTAssertEqual(like.value as? String, "unliked")

        like.tap()
        XCTAssertEqual(like.value as? String, "liked")
    }

    func testDoubleTapLikeInFullMode() {
        launchAuthenticatedFeedsTab()

        let like = app.buttons[TestIDs.Feeds.postLike(uiTestPostID)]
        XCTAssertEqual(like.value as? String, "unliked")

        let doubleTapID = TestIDs.Feeds.postDoubleTapArea(uiTestPostID)
        let zoneQuery = app.descendants(matching: .any).matching(NSPredicate(format: "identifier == %@", doubleTapID))
        let zone = zoneQuery.element(boundBy: 0)
        XCTAssertTrue(zone.waitForExistence(timeout: 8))
        zone.doubleTap()

        XCTAssertEqual(like.value as? String, "liked")
    }

    func testOpenComments() {
        launchAuthenticatedFeedsTab()

        app.buttons[TestIDs.Feeds.postComments(uiTestPostID)].tap()

        assertExists(TestIDs.Feeds.commentsSheet)
        XCTAssertTrue(app.staticTexts["Nice work!"].waitForExistence(timeout: 8))
    }

    func testNavigateToAuthorProfile() {
        launchAuthenticatedFeedsTab()

        app.buttons[TestIDs.Feeds.postAuthor(uiTestPostID)].tap()

        assertExists(TestIDs.Feeds.profileOtherUser)
    }

    func testNavigateToWorkoutDetailsFromPost() {
        launchAuthenticatedFeedsTab()

        let exercise = app.buttons[TestIDs.Feeds.postExercise(uiTestPostID, index: 1)]
        XCTAssertTrue(exercise.waitForExistence(timeout: 8))
        exercise.tap()

        assertExists(TestIDs.Feeds.workoutInfoScreen)
    }

    func testOpenFriendsScreen() {
        launchAuthenticatedFeedsTab()

        element(TestIDs.Feeds.topBarFriends).tap()

        assertExists(TestIDs.Feeds.friendsScreen)
    }

    func testOpenChatAndSendMessage() {
        launchAuthenticatedFeedsTab()

        element(TestIDs.Feeds.feedTab("friends")).tap()
        assertExists(TestIDs.Feeds.contentLoaded)

        element(TestIDs.Feeds.community(uiTestDirectCommunityID)).tap()

        assertExists(TestIDs.Feeds.chatScreen)

        let input = app.descendants(matching: .any)[TestIDs.Feeds.chatInput]
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        input.tap()
        input.typeText("Hello from UITest")

        app.buttons[TestIDs.Feeds.chatSend].tap()

        XCTAssertTrue(app.staticTexts["Hello from UITest"].waitForExistence(timeout: 8))
    }

    func testOpenCalendarFromFeeds() {
        launchAuthenticatedFeedsTab()

        element(TestIDs.Feeds.topBarCalendar).tap()

        assertExists(TestIDs.Feeds.calendarScreen)
    }

    func testWorkoutShareRecipientSelection() {
        launchApp(
            configuration: AppLaunchConfiguration(openWorkoutShareRoute: true)
        )

        let feedOption = app.buttons[TestIDs.Feeds.workoutShareOptionFeed]
        XCTAssertTrue(feedOption.waitForExistence(timeout: 12))

        let primary = app.buttons[TestIDs.Feeds.workoutSharePrimary]
        XCTAssertTrue(primary.waitForExistence(timeout: 8))
        XCTAssertTrue(primary.isEnabled)

        feedOption.tap()
        XCTAssertFalse(primary.isEnabled)

        feedOption.tap()
        XCTAssertTrue(primary.isEnabled)
    }

    func testWorkoutShareSuccessfulSend() {
        launchApp(
            configuration: AppLaunchConfiguration(openWorkoutShareRoute: true)
        )

        let primary = app.buttons[TestIDs.Feeds.workoutSharePrimary]
        XCTAssertTrue(primary.waitForExistence(timeout: 12))

        primary.tap()
        primary.tap()
        primary.tap()

        assertExists(TestIDs.Feeds.workoutShareSuccess)
    }
}

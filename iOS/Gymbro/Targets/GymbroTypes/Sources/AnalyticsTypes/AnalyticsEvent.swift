import Foundation

public enum AnalyticsEvent {

    case screenViewed(screen: AnalyticsScreen)

    case workoutCreated(workoutId: String, exerciseCount: Int, workoutType: String)
    case workoutPremadeAdded(workoutId: String, workoutName: String)
    case workoutCompleted(workoutId: String, durationSeconds: Int, exerciseCount: Int)
    case workoutGenerated(promptLength: Int, exerciseCount: Int)

    case userLoggedIn
    case userLoggedOut
    case userRegistered

    case feedsTabSelected(tab: String)
    case feedsPostLiked(postId: String, isLiked: Bool)
    case feedsPostAuthorTapped(postId: String)
    case feedsPostCommentTapped(postId: String)
    case feedsPostExerciseTapped(postId: String)
    case feedsPostShowAllExercises(postId: String)

    case feedsChatCreationOpened
    case feedsChatCreationDismissed
    case feedsChatTypeSelected(type: String)
    case feedsDirectChatPersonSelected(personId: String)
    case feedsGroupChatCreated(memberCount: Int)
    case feedsGroupMemberToggled(personId: String, selectedCount: Int)
    case feedsCommunityOpened(communityId: String)

    case peopleSegmentSelected(segment: String)
    case peoplePersonOpened(personId: String)
    case peopleFollowToggled(personId: String, isFollowing: Bool)
    case peopleProfileOpened(personId: String)
    case peopleMessageOpened(personId: String)

    case chatMessageSent(isGroup: Bool)
    case chatReactionAdded(emoji: String)
    case chatReactionToggled(emoji: String)
    case chatWorkoutMessageTapped(workoutId: String)
    case chatGroupInfoOpened
    case chatGroupInfoSaved
    case chatGroupParticipantRemoved
    case chatGroupPeopleAdded(count: Int)
    case chatGroupDeleted

    case calendarMonthChanged(direction: String)
    case calendarPersonSelected(personId: String)
    case calendarDayTapped(hasMyWorkout: Bool, hasPartnerWorkout: Bool)
    case calendarMyWorkoutOpened
    case calendarPartnerWorkoutOpened

    case profilePrimaryActionTapped(action: String, isOwnProfile: Bool)
    case profileRelationshipFollowTapped(targetUserId: String, isFollowingAfter: Bool)
    case profileRelationshipMessageTapped(targetUserId: String)
    case profileRelationshipPostsTapped(targetUserId: String, isOwnProfile: Bool)
    case profileEditSaved
    case settingsRowOpened(itemId: String)
    case settingsToggleChanged(itemId: String, isOn: Bool)
    case profileStatisticsScreenViewed(isOwnProfile: Bool)
    case statisticsChartSelected(chartKind: String, selectionId: String)

    case errorOccurred(screen: String, message: String)
    case errorRetryTapped(screen: String)
}

public enum AnalyticsScreen: String {
    case workoutList
    case workoutBuilder
    case workoutBuilderForType
    case workoutInfo
    case workoutPlayer
    case workoutGenerator
    case feedsMain
    case feedsPeople
    case feedsChat
    case feedsCalendar
    case profile
    case profileEdit = "profile_edit"
    case profileSettings = "profile_settings"
    case profileStatistics = "profile_statistics"
    case auth
    case home
}

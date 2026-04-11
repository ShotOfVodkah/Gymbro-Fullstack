import Foundation

public enum AnalyticsEvent {
    // Навигация
    case screenViewed(screen: AnalyticsScreen)

    // Тренировки
    case workoutCreated(workoutId: String, exerciseCount: Int, workoutType: String)
    case workoutPremadeAdded(workoutId: String, workoutName: String)
    case workoutCompleted(workoutId: String, durationSeconds: Int, exerciseCount: Int)
    case workoutGenerated(promptLength: Int, exerciseCount: Int)

    // Авторизация
    case userLoggedIn
    case userLoggedOut
    case userRegistered

    // Feeds — лента
    case feedsTabSelected(tab: String)
    case feedsPostLiked(postId: String, isLiked: Bool)
    case feedsPostAuthorTapped(postId: String)
    case feedsPostCommentTapped(postId: String)
    case feedsPostExerciseTapped(postId: String)
    case feedsPostShowAllExercises(postId: String)

    // Feeds — создание чата
    case feedsChatCreationOpened
    case feedsChatCreationDismissed
    case feedsChatTypeSelected(type: String)
    case feedsDirectChatPersonSelected(personId: String)
    case feedsGroupChatCreated(memberCount: Int)
    case feedsGroupMemberToggled(personId: String, selectedCount: Int)
    case feedsCommunityOpened(communityId: String)

    // People
    case peopleSegmentSelected(segment: String)
    case peoplePersonOpened(personId: String)
    case peopleFollowToggled(personId: String, isFollowing: Bool)
    case peopleProfileOpened(personId: String)
    case peopleMessageOpened(personId: String)

    // Chat
    case chatMessageSent(isGroup: Bool)
    case chatReactionAdded(emoji: String)
    case chatReactionToggled(emoji: String)
    case chatWorkoutMessageTapped(workoutId: String)
    case chatGroupInfoOpened
    case chatGroupInfoSaved
    case chatGroupParticipantRemoved
    case chatGroupPeopleAdded(count: Int)
    case chatGroupDeleted

    // Calendar
    case calendarMonthChanged(direction: String)
    case calendarPersonSelected(personId: String)
    case calendarDayTapped(hasMyWorkout: Bool, hasPartnerWorkout: Bool)
    case calendarMyWorkoutOpened
    case calendarPartnerWorkoutOpened

    // Ошибки / retry
    case errorOccurred(screen: String, message: String)
    case errorRetryTapped(screen: String)
}

public enum AnalyticsScreen: String {
    case workoutList
    case workoutBuilder
    case workoutBuilderForType
    case workoutInfo
    case workoutPlayer
    case feedsMain
    case feedsPeople
    case feedsChat
    case feedsCalendar
    case profile
    case auth
    case home
}

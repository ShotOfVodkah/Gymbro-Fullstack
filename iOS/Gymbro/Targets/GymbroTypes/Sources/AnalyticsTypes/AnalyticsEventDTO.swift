import Foundation

public struct AnalyticsEventDTO: Codable, Sendable {
    public let eventName: String
    public let properties: [String: String]
    public let timestamp: Date
    public let sessionId: String
    public let userId: String?
    public let platform: String
    public let appVersion: String

    public init(
        eventName: String,
        properties: [String: String],
        timestamp: Date,
        sessionId: String,
        userId: String?,
        platform: String,
        appVersion: String
    ) {
        self.eventName = eventName
        self.properties = properties
        self.timestamp = timestamp
        self.sessionId = sessionId
        self.userId = userId
        self.platform = platform
        self.appVersion = appVersion
    }
}

public extension AnalyticsEvent {
    func toDTO(sessionId: String, userId: String?) -> AnalyticsEventDTO {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        return AnalyticsEventDTO(
            eventName: eventName,
            properties: properties,
            timestamp: Date(),
            sessionId: sessionId,
            userId: userId,
            platform: "iOS",
            appVersion: appVersion
        )
    }

    var eventName: String {
        switch self {
        case .screenViewed: return "screen_viewed"
        case .workoutCreated: return "workout_created"
        case .workoutPremadeAdded: return "workout_premade_added"
        case .workoutCompleted: return "workout_completed"
        case .workoutGenerated: return "workout_generated"
        case .userLoggedIn: return "user_logged_in"
        case .userLoggedOut: return "user_logged_out"
        case .userRegistered: return "user_registered"
        case .feedsTabSelected: return "feeds_tab_selected"
        case .feedsPostLiked: return "feeds_post_liked"
        case .feedsPostAuthorTapped: return "feeds_post_author_tapped"
        case .feedsPostCommentTapped: return "feeds_post_comment_tapped"
        case .feedsPostExerciseTapped: return "feeds_post_exercise_tapped"
        case .feedsPostShowAllExercises: return "feeds_post_show_all_exercises"
        case .feedsChatCreationOpened: return "feeds_chat_creation_opened"
        case .feedsChatCreationDismissed: return "feeds_chat_creation_dismissed"
        case .feedsChatTypeSelected: return "feeds_chat_type_selected"
        case .feedsDirectChatPersonSelected: return "feeds_direct_chat_person_selected"
        case .feedsGroupChatCreated: return "feeds_group_chat_created"
        case .feedsGroupMemberToggled: return "feeds_group_member_toggled"
        case .feedsCommunityOpened: return "feeds_community_opened"
        case .peopleSegmentSelected: return "people_segment_selected"
        case .peoplePersonOpened: return "people_person_opened"
        case .peopleFollowToggled: return "people_follow_toggled"
        case .peopleProfileOpened: return "people_profile_opened"
        case .peopleMessageOpened: return "people_message_opened"
        case .chatMessageSent: return "chat_message_sent"
        case .chatReactionAdded: return "chat_reaction_added"
        case .chatReactionToggled: return "chat_reaction_toggled"
        case .chatWorkoutMessageTapped: return "chat_workout_message_tapped"
        case .chatGroupInfoOpened: return "chat_group_info_opened"
        case .chatGroupInfoSaved: return "chat_group_info_saved"
        case .chatGroupParticipantRemoved: return "chat_group_participant_removed"
        case .chatGroupPeopleAdded: return "chat_group_people_added"
        case .chatGroupDeleted: return "chat_group_deleted"
        case .calendarMonthChanged: return "calendar_month_changed"
        case .calendarPersonSelected: return "calendar_person_selected"
        case .calendarDayTapped: return "calendar_day_tapped"
        case .calendarMyWorkoutOpened: return "calendar_my_workout_opened"
        case .calendarPartnerWorkoutOpened: return "calendar_partner_workout_opened"
        case .errorOccurred: return "error_occurred"
        case .errorRetryTapped: return "error_retry_tapped"
        }
    }

    var properties: [String: String] {
        switch self {
        case .screenViewed(let screen):
            return ["screen": screen.rawValue]
        case .workoutCreated(let workoutId, let exerciseCount, let workoutType):
            return ["workout_id": workoutId, "exercise_count": "\(exerciseCount)", "workout_type": workoutType]
        case .workoutPremadeAdded(let workoutId, let workoutName):
            return ["workout_id": workoutId, "workout_name": workoutName]
        case .workoutCompleted(let workoutId, let durationSeconds, let exerciseCount):
            return ["workout_id": workoutId, "duration_seconds": "\(durationSeconds)", "exercise_count": "\(exerciseCount)"]
        case .workoutGenerated(let promptLength, let exerciseCount):
            return ["prompt_length": "\(promptLength)", "exercise_count": "\(exerciseCount)"]
        case .userLoggedIn, .userLoggedOut, .userRegistered:
            return [:]
        case .feedsTabSelected(let tab):
            return ["tab": tab]
        case .feedsPostLiked(let postId, let isLiked):
            return ["post_id": postId, "is_liked": "\(isLiked)"]
        case .feedsPostAuthorTapped(let postId):
            return ["post_id": postId]
        case .feedsPostCommentTapped(let postId):
            return ["post_id": postId]
        case .feedsPostExerciseTapped(let postId):
            return ["post_id": postId]
        case .feedsPostShowAllExercises(let postId):
            return ["post_id": postId]
        case .feedsChatCreationOpened, .feedsChatCreationDismissed:
            return [:]
        case .feedsChatTypeSelected(let type):
            return ["type": type]
        case .feedsDirectChatPersonSelected(let personId):
            return ["person_id": personId]
        case .feedsGroupChatCreated(let memberCount):
            return ["member_count": "\(memberCount)"]
        case .feedsGroupMemberToggled(let personId, let selectedCount):
            return ["person_id": personId, "selected_count": "\(selectedCount)"]
        case .feedsCommunityOpened(let communityId):
            return ["community_id": communityId]
        case .peopleSegmentSelected(let segment):
            return ["segment": segment]
        case .peoplePersonOpened(let personId):
            return ["person_id": personId]
        case .peopleFollowToggled(let personId, let isFollowing):
            return ["person_id": personId, "is_following": "\(isFollowing)"]
        case .peopleProfileOpened(let personId):
            return ["person_id": personId]
        case .peopleMessageOpened(let personId):
            return ["person_id": personId]
        case .chatMessageSent(let isGroup):
            return ["is_group": "\(isGroup)"]
        case .chatReactionAdded(let emoji):
            return ["emoji": emoji]
        case .chatReactionToggled(let emoji):
            return ["emoji": emoji]
        case .chatWorkoutMessageTapped(let workoutId):
            return ["workout_id": workoutId]
        case .chatGroupInfoOpened, .chatGroupInfoSaved, .chatGroupParticipantRemoved, .chatGroupDeleted:
            return [:]
        case .chatGroupPeopleAdded(let count):
            return ["count": "\(count)"]
        case .calendarMonthChanged(let direction):
            return ["direction": direction]
        case .calendarPersonSelected(let personId):
            return ["person_id": personId]
        case .calendarDayTapped(let hasMyWorkout, let hasPartnerWorkout):
            return ["has_my_workout": "\(hasMyWorkout)", "has_partner_workout": "\(hasPartnerWorkout)"]
        case .calendarMyWorkoutOpened, .calendarPartnerWorkoutOpened:
            return [:]
        case .errorOccurred(let screen, let message):
            return ["screen": screen, "message": message]
        case .errorRetryTapped(let screen):
            return ["screen": screen]
        }
    }
}

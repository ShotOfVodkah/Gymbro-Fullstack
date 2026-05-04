import Foundation

public struct FeedAuthorPreviewResponse: Decodable, Sendable {
    let id: String
    let name: String
    let avatar_url: String
}

public struct FeedCommunityPreviewResponse: Decodable, Sendable {
    let id: String
    let title: String
}

public struct FeedWorkoutExercisePreviewResponse: Decodable, Sendable {
    let id: String
    let name: String
    let type: String
    let muscleGroup: String
    let sets: Int?
    let reps: Int?
    let weightKg: Double?
    let durationMinutes: Int?
    let pace: String?
    let holdSeconds: Int?
    let breathCount: Int?
}

public struct FeedWorkoutPreviewResponse: Decodable, Sendable {
    let id: String
    let title: String
    let category: String
    let duration_minutes: Int
    let exercise_count: Int
    let exercises_preview: [FeedWorkoutExercisePreviewResponse]
}

public struct FeedPostItemResponse: Decodable, Sendable {
    let id: String
    let author: FeedAuthorPreviewResponse
    let community: FeedCommunityPreviewResponse?
    let workout: FeedWorkoutPreviewResponse?
    let description: String
    let location: String?
    let created_at: Date
    let likes_count: Int
    let comments_count: Int
    let is_liked: Bool
    let kind: String
    let is_from_following: Bool
    let is_from_direct_chat: Bool
    let is_from_group_community: Bool
}

public struct FeedPageResponse: Decodable, Sendable {
    public let items: [FeedPostItemResponse]
    public let next_cursor: Date?
    public let has_more: Bool
    
    public init(
        items: [FeedPostItemResponse],
        next_cursor: Date?,
        has_more: Bool
    ) {
        self.items = items
        self.next_cursor = next_cursor
        self.has_more = has_more
    }
}

public struct FeedCommunityItemResponse: Decodable {
    public let id: String
    public let title: String
    public let display_title: String
    public let kind: String
    public let icon: String
    public let is_system_image: Bool
    public let members_count: Int
    public let unread_count: Int
    public let last_message_preview: String?
    public let last_message_at: Date?

    public init(
        id: String,
        title: String,
        display_title: String,
        kind: String,
        icon: String,
        is_system_image: Bool,
        members_count: Int,
        unread_count: Int,
        last_message_preview: String?,
        last_message_at: Date?
    ) {
        self.id = id
        self.title = title
        self.display_title = display_title
        self.kind = kind
        self.icon = icon
        self.is_system_image = is_system_image
        self.members_count = members_count
        self.unread_count = unread_count
        self.last_message_preview = last_message_preview
        self.last_message_at = last_message_at
    }
}

public struct FeedCommentResponse: Decodable {
    let id: String
    let author: FeedAuthorPreviewResponse
    let text: String
    let created_at: Date
}

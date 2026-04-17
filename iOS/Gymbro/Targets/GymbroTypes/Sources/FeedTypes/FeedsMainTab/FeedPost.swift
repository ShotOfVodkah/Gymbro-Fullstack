import Foundation

public struct FeedPost: Identifiable, Hashable {
    public let id: String
    public let serverID: String
    public let createdAt: Date
    
    public let authorName: String
    public let authorAvatar: String
    public let postedAt: String
    public let title: String
    public let coverImageName: String
    public let category: String
    public let duration: String
    public let timeAgo: String
    public let location: String?
    public let description: String
    public let exercises: [ExerciseItem]
    public let totalExercisesCount: Int
    
    public var likesCount: Int
    public var commentsCount: Int
    public var isLiked: Bool
    
    public let kind: FeedPostKind
    
    public let isFromFollowing: Bool
    public let isFromDirectChat: Bool
    public let isFromGroupCommunity: Bool
    
    public init(
        id: String,
        serverID: String,
        createdAt: Date,
        authorName: String,
        authorAvatar: String,
        postedAt: String,
        title: String,
        coverImageName: String,
        category: String,
        duration: String,
        timeAgo: String,
        location: String?,
        description: String,
        exercises: [ExerciseItem],
        totalExercisesCount: Int,
        likesCount: Int,
        commentsCount: Int,
        isLiked: Bool,
        kind: FeedPostKind,
        isFromFollowing: Bool,
        isFromDirectChat: Bool,
        isFromGroupCommunity: Bool
    ) {
        self.id = id
        self.serverID = serverID
        self.createdAt = createdAt
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.postedAt = postedAt
        self.title = title
        self.coverImageName = coverImageName
        self.category = category
        self.duration = duration
        self.timeAgo = timeAgo
        self.location = location
        self.description = description
        self.exercises = exercises
        self.totalExercisesCount = totalExercisesCount
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.isLiked = isLiked
        self.kind = kind
        self.isFromFollowing = isFromFollowing
        self.isFromDirectChat = isFromDirectChat
        self.isFromGroupCommunity = isFromGroupCommunity
    }
}

public enum FeedPostKind: Hashable {
    case personal
    case friend
    case group
}

extension FeedPost {
    public init(response: FeedPostItemResponse) {
        self.id = response.id
        self.serverID = response.id
        self.createdAt = response.created_at
        self.authorName = response.author.name
        self.authorAvatar = response.author.avatar_url
        self.postedAt = Self.formattedDate(response.created_at)
        self.title = response.workout?.title ?? String(localized: "chat.fallback.workout", bundle: .module)
        self.coverImageName = "photo"
        self.category = response.workout?.category.capitalized
            ?? String(localized: "chat.fallback.workout", bundle: .module)
        self.duration = response.workout.map { "\($0.duration_minutes) min" } ?? "-"
        self.timeAgo = Self.timeAgoString(from: response.created_at)
        self.location = response.location
        self.description = response.description
        self.exercises = response.workout?.exercises_preview.map(Self.mapExercisePreview(_:)) ?? []
        self.totalExercisesCount = response.workout?.exercise_count ?? 0
        self.likesCount = response.likes_count
        self.commentsCount = response.comments_count
        self.isLiked = response.is_liked
        self.kind = Self.mapKind(response.kind)
        self.isFromFollowing = response.is_from_following
        self.isFromDirectChat = response.is_from_direct_chat
        self.isFromGroupCommunity = response.is_from_group_community
    }
    
    private static func mapExercisePreview(_ item: FeedWorkoutExercisePreviewResponse) -> ExerciseItem {
        let muscleGroup = mapMuscleGroup(item.muscleGroup)
        
        switch item.type {
        case "strength":
            return .strength(
                StrengthExercise(
                    id: item.id,
                    name: item.name,
                    muscleGroup: muscleGroup,
                    sets: item.sets ?? 0,
                    reps: item.reps ?? 0,
                    weightKg: item.weightKg ?? 0
                )
            )
        case "cardio":
            return .cardio(
                CardioExercise(
                    id: item.id,
                    name: item.name,
                    muscleGroup: muscleGroup,
                    durationMinutes: item.durationMinutes ?? 0,
                    pace: mapPace(item.pace)
                )
            )
        case "yoga":
            return .yoga(
                YogaExercise(
                    id: item.id,
                    name: item.name,
                    muscleGroup: muscleGroup,
                    holdSeconds: item.holdSeconds ?? 0,
                    breathCount: item.breathCount ?? 0
                )
            )
        default:
            return .fallback(
                DefaultExercise(
                    id: item.id,
                    name: item.name,
                    muscleGroup: muscleGroup
                )
            )
        }
    }
    
    private static func mapMuscleGroup(_ rawValue: String) -> MuscleGroup {
        switch rawValue {
        case "chest": return .chest
        case "back": return .back
        case "shoulders": return .shoulders
        case "biceps": return .biceps
        case "triceps": return .triceps
        case "legs": return .legs
        case "glutes": return .glutes
        case "core": return .core
        case "full_body": return .fullBody
        default: return .fullBody
        }
    }
    
    private static func mapPace(_ rawValue: String?) -> PaceType {
        switch rawValue {
        case "walk": return .walk
        case "run": return .run
        case "sprint": return .sprint
        case "recovery": return .recovery
        default: return .jog
        }
    }
    
    private static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private static func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private static func mapKind(_ rawValue: String) -> FeedPostKind {
        switch rawValue {
        case "friend": return .friend
        case "group": return .group
        default: return .personal
        }
    }
    
    public static func == (lhs: FeedPost, rhs: FeedPost) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

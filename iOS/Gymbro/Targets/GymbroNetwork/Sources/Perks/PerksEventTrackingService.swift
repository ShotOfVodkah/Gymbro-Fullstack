import Foundation
import GymbroTypes

public protocol PerksEventTrackingService {
    func trackWorkoutCompleted(startedAt: Date?, hasNotes: Bool, muscleGroupsCount: Int) async
    func trackWorkoutShared() async
    func trackPostCommentReceived(postId: String, commentsCount: Int) async
    func trackPostLikeReceived(postId: String, likesCount: Int) async
    func trackProfileOpened(userId: String) async
    func trackFriendWorkoutCommented() async
    func trackCustomWorkoutCreated() async
}

public final class PerksEventTrackingServiceImpl: PerksEventTrackingService {
    
    private let client: any PerksClient
    
    public init(client: any PerksClient) {
        self.client = client
    }
    
    public func trackWorkoutCompleted(
        startedAt: Date?,
        hasNotes: Bool,
        muscleGroupsCount: Int
    ) async {
        await send(
            type: "workout_completed",
            metadata: workoutMetadata(startedAt: startedAt)
        )
        
        if !hasNotes {
            await send(type: "workout_without_notes")
        }
        
        if muscleGroupsCount >= 3 {
            await send(
                type: "workout_three_muscle_groups",
                metadata: ["muscle_groups_count": "\(muscleGroupsCount)"]
            )
        }
    }
    
    public func trackWorkoutShared() async {
        await send(type: "workout_shared")
    }
    
    public func trackPostCommentReceived(postId: String, commentsCount: Int) async {
        await send(
            type: "post_comment_received",
            metadata: [
                "post_id": postId,
                "comments_count": "\(commentsCount)"
            ]
        )
    }
    
    public func trackPostLikeReceived(postId: String, likesCount: Int) async {
        await send(
            type: "post_liked_received",
            metadata: [
                "post_id": postId,
                "likes_count": "\(likesCount)"
            ]
        )
    }
    
    public func trackProfileOpened(userId: String) async {
        await send(
            type: "profile_opened",
            metadata: ["target_user_id": userId]
        )
    }
    
    public func trackFriendWorkoutCommented() async {
        await send(type: "friend_workout_commented")
    }
    
    public func trackCustomWorkoutCreated() async {
        await send(type: "custom_workout_created")
    }
    
    private func send(
        type: String,
        metadata: [String: String] = [:]
    ) async {
        do {
            try await client.sendPerksEvent(
                PerksEventRequest(
                    type: type,
                    metadata: metadata,
                    createdAt: Date()
                )
            )
        } catch {
            print("Perks event failed:", type, error)
        }
    }
    
    private func workoutMetadata(startedAt: Date?) -> [String: String] {
        guard let startedAt else { return [:] }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: startedAt)
        let minute = calendar.component(.minute, from: startedAt)
        let weekday = calendar.weekdaySymbols[calendar.component(.weekday, from: startedAt) - 1].lowercased()
        
        return [
            "weekday": weekday,
            "hour": "\(hour)",
            "time": String(format: "%02d:%02d", hour, minute)
        ]
    }
}

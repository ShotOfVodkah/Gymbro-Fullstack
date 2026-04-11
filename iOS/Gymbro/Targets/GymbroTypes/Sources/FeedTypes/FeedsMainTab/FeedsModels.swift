import Foundation

struct FeedAuthorPreviewResponse: Decodable {
    let id: String
    let name: String
    let avatar_url: String
}

struct FeedCommunityPreviewResponse: Decodable {
    let id: String
    let title: String
}

struct FeedWorkoutExercisePreviewResponse: Decodable {
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

struct FeedWorkoutPreviewResponse: Decodable {
    let id: String
    let title: String
    let category: String
    let duration_minutes: Int
    let exercise_count: Int
    let exercises_preview: [FeedWorkoutExercisePreviewResponse]
}

public struct FeedPostItemResponse: Decodable {
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
    let is_from_joined_community: Bool
}

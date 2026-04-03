import Foundation

enum FeedsMockData {
    
    static let communities: [FeedCommunity] = [
        FeedCommunity(title: "Alex", icon: "person.fill"),
        FeedCommunity(title: "Gym Squad", icon: "figure.strengthtraining.traditional", isSystemImage: true, isGroup: true),
        FeedCommunity(title: "Maria", icon: "person.fill", isSystemImage: true),
        FeedCommunity(title: "Running Club", icon: "figure.run", isSystemImage: true, isGroup: true)
    ]

    static let posts: [FeedPost] = [
        FeedPost(
            authorName: "Alex Petrov",
            authorAvatar: "squareroot",
            postedAt: "2 hours ago",
            title: "Morning Run",
            coverImageName: "feed_running",
            category: "Cardio",
            duration: "45 min",
            timeAgo: "2 hours ago",
            location: "Gorky Park, Moscow",
            description: "Great run today! The weather was perfect ☀️",
            exercises: [
                FeedExercise(title: "Warm-up Walk", subtitle: "5 min", imageName: "figure.run.circle"),
                FeedExercise(title: "Light Jog", subtitle: "30 min", imageName: ""),
                FeedExercise(title: "Cool-down Walk", subtitle: "10 min", imageName: "")
            ],
            likesCount: 24,
            commentsCount: 5,
            isLiked: false
        ),
        FeedPost(
            authorName: "Maria Ivanova",
            authorAvatar: "angle",
            postedAt: "5 hours ago",
            title: "Recovery Yoga Session",
            coverImageName: "feed_yoga",
            category: "Yoga",
            duration: "30 min",
            timeAgo: "5 hours ago",
            location: nil,
            description: "Did a short recovery session today focusing on stretching and breathing.",
            exercises: [
                FeedExercise(title: "Breathing Warm-up", subtitle: "5 min", imageName: ""),
                FeedExercise(title: "Back Stretch Flow", subtitle: "15 min", imageName: "figure.roll")
            ],
            likesCount: 18,
            commentsCount: 3,
            isLiked: true
        )
    ]
}

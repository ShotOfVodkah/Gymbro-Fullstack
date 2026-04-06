import Foundation

enum FeedsMockData {
    
    static let communities: [FeedCommunity] = [
        FeedCommunity(
            title: "Alex",
            icon: "person.fill",
            isSystemImage: true,
            kind: .directPerson
        ),
        FeedCommunity(
            title: "Maria",
            icon: "person.fill",
            isSystemImage: true,
            kind: .directPerson
        ),
        FeedCommunity(
            title: "Coach Dan",
            icon: "person.fill",
            isSystemImage: true,
            kind: .directPerson
        ),
        FeedCommunity(
            title: "Lena",
            icon: "person.fill",
            isSystemImage: true,
            kind: .directPerson
        ),
        FeedCommunity(
            title: "Gym Squad",
            icon: "figure.strengthtraining.traditional",
            isSystemImage: true,
            kind: .joinedGroup
        ),
        FeedCommunity(
            title: "Running Club",
            icon: "figure.run",
            isSystemImage: true,
            kind: .joinedGroup
        ),
        FeedCommunity(
            title: "Mobility Team",
            icon: "figure.cooldown",
            isSystemImage: true,
            kind: .joinedGroup
        ),
        FeedCommunity(
            title: "Weekend Hike",
            icon: "figure.hiking",
            isSystemImage: true,
            kind: .joinedGroup
        )
    ]
    
    static let posts: [FeedPost] = [
        
        // MARK: - Friend / direct posts
        
        FeedPost(
            authorName: "Alex Petrov",
            authorAvatar: "figure.run",
            postedAt: "2 hours ago",
            title: "Morning Run",
            coverImageName: "feed_running",
            category: "Cardio",
            duration: "45 min",
            timeAgo: "2 hours ago",
            location: "Gorky Park, Moscow",
            description: "Great run today! The weather was perfect and the pace felt really smooth.",
            exercises: [
                FeedExercise(title: "Warm-up Walk", subtitle: "5 min", imageName: "figure.walk"),
                FeedExercise(title: "Light Jog", subtitle: "30 min", imageName: "figure.run"),
                FeedExercise(title: "Cool-down Walk", subtitle: "10 min", imageName: "figure.walk")
            ],
            likesCount: 24,
            commentsCount: 5,
            isLiked: false,
            kind: .friend,
            isFromJoinedCommunity: false
        ),
        
        FeedPost(
            authorName: "Maria Ivanova",
            authorAvatar: "figure.cooldown",
            postedAt: "5 hours ago",
            title: "Recovery Yoga Session",
            coverImageName: "feed_yoga",
            category: "Yoga",
            duration: "30 min",
            timeAgo: "5 hours ago",
            location: nil,
            description: "Did a short recovery session today focusing on stretching, breathing, and lower back mobility.",
            exercises: [
                FeedExercise(title: "Breathing Warm-up", subtitle: "5 min", imageName: "lungs.fill"),
                FeedExercise(title: "Back Stretch Flow", subtitle: "15 min", imageName: "figure.cooldown")
            ],
            likesCount: 18,
            commentsCount: 3,
            isLiked: true,
            kind: .friend,
            isFromJoinedCommunity: false
        ),
        
        FeedPost(
            authorName: "Coach Dan",
            authorAvatar: "figure.strengthtraining.traditional",
            postedAt: "Yesterday",
            title: "Upper Body Technique Check",
            coverImageName: "feed_strength",
            category: "Strength",
            duration: "40 min",
            timeAgo: "1 day ago",
            location: "GymBro Studio",
            description: "Focused on slower tempo and cleaner bench press mechanics today.",
            exercises: [
                FeedExercise(title: "Band Warm-up", subtitle: "7 min", imageName: "figure.strengthtraining.functional"),
                FeedExercise(title: "Bench Press", subtitle: "4 x 8", imageName: "dumbbell.fill"),
                FeedExercise(title: "Incline Dumbbell Press", subtitle: "3 x 10", imageName: "dumbbell"),
                FeedExercise(title: "Cable Fly", subtitle: "3 x 12", imageName: "bolt.heart")
            ],
            likesCount: 31,
            commentsCount: 8,
            isLiked: false,
            kind: .friend,
            isFromJoinedCommunity: false
        ),
        
        FeedPost(
            authorName: "Lena Volkova",
            authorAvatar: "figure.walk.motion",
            postedAt: "Yesterday",
            title: "Steps + Core Reset",
            coverImageName: "feed_walk",
            category: "Wellness",
            duration: "25 min",
            timeAgo: "1 day ago",
            location: nil,
            description: "Low-intensity walk plus short core work. Perfect reset day.",
            exercises: [
                FeedExercise(title: "Brisk Walk", subtitle: "15 min", imageName: "figure.walk"),
                FeedExercise(title: "Dead Bug", subtitle: "3 x 12", imageName: "figure.core.training"),
                FeedExercise(title: "Plank Hold", subtitle: "3 x 40 sec", imageName: "figure.strengthtraining.functional")
            ],
            likesCount: 14,
            commentsCount: 2,
            isLiked: false,
            kind: .friend,
            isFromJoinedCommunity: false
        ),
        
        // MARK: - Group posts from joined communities
        
        FeedPost(
            authorName: "Gym Squad",
            authorAvatar: "person.3.fill",
            postedAt: "3 hours ago",
            title: "Team Push Day",
            coverImageName: "feed_pushday",
            category: "Group",
            duration: "55 min",
            timeAgo: "3 hours ago",
            location: "GymBro Arena",
            description: "Strong group session today. Everyone finished the full push block together.",
            exercises: [
                FeedExercise(title: "Dynamic Warm-up", subtitle: "8 min", imageName: "figure.strengthtraining.functional"),
                FeedExercise(title: "Bench Press", subtitle: "5 x 5", imageName: "dumbbell.fill"),
                FeedExercise(title: "Shoulder Press", subtitle: "4 x 8", imageName: "figure.strengthtraining.traditional"),
                FeedExercise(title: "Triceps Burnout", subtitle: "3 rounds", imageName: "flame.fill")
            ],
            likesCount: 42,
            commentsCount: 11,
            isLiked: true,
            kind: .group,
            isFromJoinedCommunity: true
        ),
        
        FeedPost(
            authorName: "Running Club",
            authorAvatar: "person.3.sequence.fill",
            postedAt: "6 hours ago",
            title: "Evening Intervals",
            coverImageName: "feed_intervals",
            category: "Running",
            duration: "50 min",
            timeAgo: "6 hours ago",
            location: "River Track",
            description: "Interval session with the club. Fast repeats, short recovery, great energy.",
            exercises: [
                FeedExercise(title: "Warm-up Jog", subtitle: "10 min", imageName: "figure.run"),
                FeedExercise(title: "6 x 400m Intervals", subtitle: "Main set", imageName: "speedometer"),
                FeedExercise(title: "Cooldown Walk", subtitle: "8 min", imageName: "figure.walk")
            ],
            likesCount: 27,
            commentsCount: 6,
            isLiked: false,
            kind: .group,
            isFromJoinedCommunity: true
        ),
        
        FeedPost(
            authorName: "Mobility Team",
            authorAvatar: "figure.cooldown",
            postedAt: "8 hours ago",
            title: "Hip Mobility Flow",
            coverImageName: "feed_mobility",
            category: "Mobility",
            duration: "20 min",
            timeAgo: "8 hours ago",
            location: nil,
            description: "Short group flow focused on hips, hamstrings, and posture after desk work.",
            exercises: [
                FeedExercise(title: "Hip Openers", subtitle: "6 min", imageName: "figure.flexibility"),
                FeedExercise(title: "Hamstring Stretch", subtitle: "6 min", imageName: "figure.cooldown"),
                FeedExercise(title: "Spine Rotation", subtitle: "8 min", imageName: "arrow.triangle.2.circlepath")
            ],
            likesCount: 19,
            commentsCount: 4,
            isLiked: false,
            kind: .group,
            isFromJoinedCommunity: true
        ),
        
        FeedPost(
            authorName: "Weekend Hike",
            authorAvatar: "figure.hiking",
            postedAt: "2 days ago",
            title: "Mountain Trail Recap",
            coverImageName: "feed_hike",
            category: "Outdoor",
            duration: "2 h 15 min",
            timeAgo: "2 days ago",
            location: "Uetliberg Trail",
            description: "Steep climbs, amazing weather, and one very dramatic group photo at the top.",
            exercises: [
                FeedExercise(title: "Climb Section", subtitle: "45 min", imageName: "figure.hiking"),
                FeedExercise(title: "Pace Walk", subtitle: "35 min", imageName: "figure.walk"),
                FeedExercise(title: "Descent Control", subtitle: "25 min", imageName: "figure.walk.motion")
            ],
            likesCount: 35,
            commentsCount: 9,
            isLiked: true,
            kind: .group,
            isFromJoinedCommunity: true
        ),
        
        // MARK: - Personal / own posts for For You
        
        FeedPost(
            authorName: "You",
            authorAvatar: "person.crop.circle.fill",
            postedAt: "Today",
            title: "Leg Day Personal Best",
            coverImageName: "feed_legs",
            category: "Strength",
            duration: "1 h 05 min",
            timeAgo: "Today",
            location: "GymBro Club",
            description: "Hit a new personal best on squats today. Felt stable, strong, and finally confident at the bottom.",
            exercises: [
                FeedExercise(title: "Cycling Warm-up", subtitle: "8 min", imageName: "bicycle"),
                FeedExercise(title: "Barbell Squat", subtitle: "5 x 5", imageName: "dumbbell.fill"),
                FeedExercise(title: "Romanian Deadlift", subtitle: "4 x 8", imageName: "figure.strengthtraining.traditional"),
                FeedExercise(title: "Walking Lunges", subtitle: "3 x 12", imageName: "figure.walk")
            ],
            likesCount: 52,
            commentsCount: 13,
            isLiked: true,
            kind: .personal,
            isFromJoinedCommunity: false
        ),
        
        FeedPost(
            authorName: "You",
            authorAvatar: "person.crop.circle.fill",
            postedAt: "2 days ago",
            title: "Quick Core Session",
            coverImageName: "feed_core",
            category: "Core",
            duration: "18 min",
            timeAgo: "2 days ago",
            location: nil,
            description: "Short and effective. Just enough to wake up the core without frying the whole body.",
            exercises: [
                FeedExercise(title: "Dead Bug", subtitle: "3 x 12", imageName: "figure.core.training"),
                FeedExercise(title: "Plank", subtitle: "3 x 45 sec", imageName: "figure.strengthtraining.functional"),
                FeedExercise(title: "Toe Taps", subtitle: "3 x 20", imageName: "figure.mixed.cardio")
            ],
            likesCount: 16,
            commentsCount: 2,
            isLiked: false,
            kind: .personal,
            isFromJoinedCommunity: false
        ),
        
        FeedPost(
            authorName: "You",
            authorAvatar: "person.crop.circle.fill",
            postedAt: "3 days ago",
            title: "Cycle Recovery Ride",
            coverImageName: "feed_cycle",
            category: "Recovery",
            duration: "35 min",
            timeAgo: "3 days ago",
            location: "Home trainer",
            description: "Very light recovery ride just to get the legs moving and loosen up after strength training.",
            exercises: [
                FeedExercise(title: "Easy Spin", subtitle: "25 min", imageName: "bicycle"),
                FeedExercise(title: "Cadence Drill", subtitle: "10 min", imageName: "speedometer")
            ],
            likesCount: 11,
            commentsCount: 1,
            isLiked: false,
            kind: .personal,
            isFromJoinedCommunity: false
        )
    ]
}

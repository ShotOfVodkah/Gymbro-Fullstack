import Foundation
import GymbroTypes

enum FeedsMockData {
    
    static let communities: [FeedCommunity] = [
        FeedCommunity(
            title: "Alex",
            icon: "person.fill",
            isSystemImage: true,
            kind: .directPerson,
            participants: [FeedsPeopleMockData.alex]
        ),
        FeedCommunity(
            title: "Maria",
            icon: "person.fill",
            isSystemImage: true,
            kind: .directPerson,
            participants: [FeedsPeopleMockData.maria]
        ),
        FeedCommunity(
            title: "Coach Dan",
            icon: "person.fill",
            isSystemImage: true,
            kind: .directPerson,
            participants: [FeedsPeopleMockData.coachDaniel]
        ),
        FeedCommunity(
            title: "Lena",
            icon: "person.fill",
            isSystemImage: true,
            kind: .directPerson,
            participants: [FeedsPeopleMockData.lena]
        ),
        FeedCommunity(
            title: "Gym Squad",
            icon: "figure.strengthtraining.traditional",
            isSystemImage: true,
            kind: .joinedGroup,
            participants: [
                FeedsPeopleMockData.alex,
                FeedsPeopleMockData.maria,
                FeedsPeopleMockData.coachDaniel
            ]
        ),
        FeedCommunity(
            title: "Running Club",
            icon: "figure.run",
            isSystemImage: true,
            kind: .joinedGroup,
            participants: [
                FeedsPeopleMockData.alex,
                FeedsPeopleMockData.lena
            ]
        ),
        FeedCommunity(
            title: "Mobility Team",
            icon: "figure.cooldown",
            isSystemImage: true,
            kind: .joinedGroup,
            participants: [
                FeedsPeopleMockData.maria,
                FeedsPeopleMockData.coachDaniel,
                FeedsPeopleMockData.lena
            ]
        ),
        FeedCommunity(
            title: "Weekend Hike",
            icon: "figure.hiking",
            isSystemImage: true,
            kind: .joinedGroup,
            participants: [
                FeedsPeopleMockData.alex,
                FeedsPeopleMockData.maria,
                FeedsPeopleMockData.lena
            ]
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
                .cardio(CardioExercise(
                    id: "alex_run_1",
                    name: "Warm-up Walk",
                    muscleGroup: .legs,
                    durationMinutes: 5,
                    pace: .walk
                )),
                .cardio(CardioExercise(
                    id: "alex_run_2",
                    name: "Light Jog",
                    muscleGroup: .legs,
                    durationMinutes: 30,
                    pace: .jog
                )),
                .cardio(CardioExercise(
                    id: "alex_run_3",
                    name: "Cool-down Walk",
                    muscleGroup: .legs,
                    durationMinutes: 10,
                    pace: .walk
                ))
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
                .yoga(YogaExercise(
                    id: "maria_yoga_1",
                    name: "Breathing Warm-up",
                    muscleGroup: .core,
                    holdSeconds: 60,
                    breathCount: 5
                )),
                .yoga(YogaExercise(
                    id: "maria_yoga_2",
                    name: "Back Stretch Flow",
                    muscleGroup: .back,
                    holdSeconds: 180,
                    breathCount: 15
                ))
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
                .fallback(DefaultExercise(
                    id: "coach_upper_1",
                    name: "Band Warm-up",
                    muscleGroup: .shoulders
                )),
                .strength(StrengthExercise(
                    id: "coach_upper_2",
                    name: "Bench Press",
                    muscleGroup: .chest,
                    sets: 4,
                    reps: 8,
                    weightKg: 70
                )),
                .strength(StrengthExercise(
                    id: "coach_upper_3",
                    name: "Incline Dumbbell Press",
                    muscleGroup: .chest,
                    sets: 3,
                    reps: 10,
                    weightKg: 24
                )),
                .strength(StrengthExercise(
                    id: "coach_upper_4",
                    name: "Cable Fly",
                    muscleGroup: .chest,
                    sets: 3,
                    reps: 12,
                    weightKg: 18
                ))
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
                .cardio(CardioExercise(
                    id: "lena_reset_1",
                    name: "Brisk Walk",
                    muscleGroup: .legs,
                    durationMinutes: 15,
                    pace: .walk
                )),
                .fallback(DefaultExercise(
                    id: "lena_reset_2",
                    name: "Dead Bug",
                    muscleGroup: .core
                )),
                .fallback(DefaultExercise(
                    id: "lena_reset_3",
                    name: "Plank Hold",
                    muscleGroup: .core
                ))
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
                .fallback(DefaultExercise(
                    id: "gymsquad_push_1",
                    name: "Dynamic Warm-up",
                    muscleGroup: .fullBody
                )),
                .strength(StrengthExercise(
                    id: "gymsquad_push_2",
                    name: "Bench Press",
                    muscleGroup: .chest,
                    sets: 5,
                    reps: 5,
                    weightKg: 75
                )),
                .strength(StrengthExercise(
                    id: "gymsquad_push_3",
                    name: "Shoulder Press",
                    muscleGroup: .shoulders,
                    sets: 4,
                    reps: 8,
                    weightKg: 40
                )),
                .fallback(DefaultExercise(
                    id: "gymsquad_push_4",
                    name: "Triceps Burnout",
                    muscleGroup: .triceps
                ))
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
                .cardio(CardioExercise(
                    id: "runclub_1",
                    name: "Warm-up Jog",
                    muscleGroup: .legs,
                    durationMinutes: 10,
                    pace: .jog
                )),
                .cardio(CardioExercise(
                    id: "runclub_2",
                    name: "6 x 400m Intervals",
                    muscleGroup: .legs,
                    durationMinutes: 32,
                    pace: .run
                )),
                .cardio(CardioExercise(
                    id: "runclub_3",
                    name: "Cooldown Walk",
                    muscleGroup: .legs,
                    durationMinutes: 8,
                    pace: .walk
                ))
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
                .yoga(YogaExercise(
                    id: "mobility_1",
                    name: "Hip Openers",
                    muscleGroup: .glutes,
                    holdSeconds: 120,
                    breathCount: 8
                )),
                .yoga(YogaExercise(
                    id: "mobility_2",
                    name: "Hamstring Stretch",
                    muscleGroup: .legs,
                    holdSeconds: 120,
                    breathCount: 8
                )),
                .yoga(YogaExercise(
                    id: "mobility_3",
                    name: "Spine Rotation",
                    muscleGroup: .back,
                    holdSeconds: 150,
                    breathCount: 10
                ))
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
                .cardio(CardioExercise(
                    id: "hike_1",
                    name: "Climb Section",
                    muscleGroup: .legs,
                    durationMinutes: 45,
                    pace: .run
                )),
                .cardio(CardioExercise(
                    id: "hike_2",
                    name: "Pace Walk",
                    muscleGroup: .legs,
                    durationMinutes: 35,
                    pace: .walk
                )),
                .cardio(CardioExercise(
                    id: "hike_3",
                    name: "Descent Control",
                    muscleGroup: .legs,
                    durationMinutes: 25,
                    pace: .recovery
                ))
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
                .cardio(CardioExercise(
                    id: "me_legs_1",
                    name: "Cycling Warm-up",
                    muscleGroup: .legs,
                    durationMinutes: 8,
                    pace: .recovery
                )),
                .strength(StrengthExercise(
                    id: "me_legs_2",
                    name: "Barbell Squat",
                    muscleGroup: .legs,
                    sets: 5,
                    reps: 5,
                    weightKg: 90
                )),
                .strength(StrengthExercise(
                    id: "me_legs_3",
                    name: "Romanian Deadlift",
                    muscleGroup: .glutes,
                    sets: 4,
                    reps: 8,
                    weightKg: 70
                )),
                .strength(StrengthExercise(
                    id: "me_legs_4",
                    name: "Walking Lunges",
                    muscleGroup: .legs,
                    sets: 3,
                    reps: 12,
                    weightKg: 18
                ))
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
                .fallback(DefaultExercise(
                    id: "me_core_1",
                    name: "Dead Bug",
                    muscleGroup: .core
                )),
                .fallback(DefaultExercise(
                    id: "me_core_2",
                    name: "Plank",
                    muscleGroup: .core
                )),
                .fallback(DefaultExercise(
                    id: "me_core_3",
                    name: "Toe Taps",
                    muscleGroup: .core
                ))
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
                .cardio(CardioExercise(
                    id: "me_cycle_1",
                    name: "Easy Spin",
                    muscleGroup: .legs,
                    durationMinutes: 25,
                    pace: .recovery
                )),
                .cardio(CardioExercise(
                    id: "me_cycle_2",
                    name: "Cadence Drill",
                    muscleGroup: .legs,
                    durationMinutes: 10,
                    pace: .jog
                ))
            ],
            likesCount: 11,
            commentsCount: 1,
            isLiked: false,
            kind: .personal,
            isFromJoinedCommunity: false
        )
    ]
}

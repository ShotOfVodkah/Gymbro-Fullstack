import Foundation
import GymbroTypes

enum PerksMockData {
    
    // MARK: - Dashboard
    
    static let dashboard = PerksDashboard(
        streak: streak,
        recentUnlocks: recentUnlocks,
        achievements: achievements,
        leaderboardPreview: leaderboard,
        myRank: myRank
    )
    
    // MARK: - Streak
    
    static let streak = StreakState(
        currentStreakWeeks: 4,
        bestStreakWeeks: 8,
        weeklyGoal: 4,
        nextWeeklyGoal: nil,
        completedThisWeek: 3,
        remainingToGoal: 0,
        weekStartDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
        weekEndDate: Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date(),
        isGoalCompleted: false,
        streakFreezeCount: 3,
        canUseStreakFreeze: true,
        wasFreezeUsedThisWeek: false
    )
    
    // MARK: - Achievements

    static let achievements: [Achievement] = [
        
        // MARK: Workout Milestones
        
        Achievement(
            id: "1",
            code: "rookie",
            name: "Rookie",
            description: "First recorded workout",
            iconName: "eyeglasses",
            category: .workoutMilestones,
            rarity: .common,
            status: .unlocked,
            progressCurrent: 1,
            progressTarget: 1,
            unlockedAt: Date().addingTimeInterval(-86400 * 30),
            isSecret: false
        ),
        
        Achievement(
            id: "2",
            code: "workouts_50",
            name: "50 Workouts",
            description: "Completed 50 workouts",
            iconName: "tortoise.circle.fill",
            category: .workoutMilestones,
            rarity: .rare,
            status: .unlocked,
            progressCurrent: 50,
            progressTarget: 50,
            unlockedAt: Date().addingTimeInterval(-86400 * 10),
            isSecret: false
        ),
        
        Achievement(
            id: "3",
            code: "workouts_100",
            name: "100 Workouts",
            description: "Completed 100 workouts",
            iconName: "hare.circle.fill",
            category: .workoutMilestones,
            rarity: .rare,
            status: .locked,
            progressCurrent: 78,
            progressTarget: 100,
            unlockedAt: nil,
            isSecret: false
        ),
        
        Achievement(
            id: "4",
            code: "workouts_200",
            name: "200 Workouts",
            description: "Completed 200 workouts",
            iconName: "bolt.circle.fill",
            category: .workoutMilestones,
            rarity: .epic,
            status: .locked,
            progressCurrent: 120,
            progressTarget: 200,
            unlockedAt: nil,
            isSecret: false
        ),
        
        Achievement(
            id: "5",
            code: "workouts_300",
            name: "300 Workouts",
            description: "Completed 300 workouts",
            iconName: "ant.circle.fill",
            category: .workoutMilestones,
            rarity: .epic,
            status: .locked,
            progressCurrent: 128,
            progressTarget: 300,
            unlockedAt: nil,
            isSecret: false
        ),
        
        Achievement(
            id: "6",
            code: "workouts_400",
            name: "400 Workouts",
            description: "Completed 400 workouts",
            iconName: "bolt.car.fill",
            category: .workoutMilestones,
            rarity: .legendary,
            status: .locked,
            progressCurrent: 128,
            progressTarget: 400,
            unlockedAt: nil,
            isSecret: false
        ),
        
        Achievement(
            id: "7",
            code: "workouts_500",
            name: "500 Workouts",
            description: "Completed 500 workouts",
            iconName: "crown.fill",
            category: .workoutMilestones,
            rarity: .legendary,
            status: .locked,
            progressCurrent: 128,
            progressTarget: 500,
            unlockedAt: nil,
            isSecret: false
        ),
        
        // MARK: Time Challenges
        
        Achievement(
            id: "8",
            code: "tough_day",
            name: "Tough Day",
            description: "Workout on a Monday",
            iconName: "bed.double.circle.fill",
            category: .timeChallenges,
            rarity: .common,
            status: .unlocked,
            progressCurrent: 1,
            progressTarget: 1,
            unlockedAt: Date().addingTimeInterval(-86400 * 5),
            isSecret: false
        ),
        
        Achievement(
            id: "9",
            code: "lazy_weekend",
            name: "Lazy Weekend",
            description: "Workout on Saturday or Sunday",
            iconName: "beach.umbrella.fill",
            category: .timeChallenges,
            rarity: .common,
            status: .unlocked,
            progressCurrent: 1,
            progressTarget: 1,
            unlockedAt: Date().addingTimeInterval(-86400 * 3),
            isSecret: false
        ),
        
        Achievement(
            id: "10",
            code: "early_riser",
            name: "Early Riser",
            description: "Workout before 7 AM",
            iconName: "sun.haze.fill",
            category: .timeChallenges,
            rarity: .rare,
            status: .unlocked,
            progressCurrent: 1,
            progressTarget: 1,
            unlockedAt: Date().addingTimeInterval(-86400),
            isSecret: false
        ),
        
        Achievement(
            id: "11",
            code: "night_owl",
            name: "Night Owl",
            description: "Workout after 11 PM",
            iconName: "moon.stars.circle.fill",
            category: .timeChallenges,
            rarity: .rare,
            status: .locked,
            progressCurrent: 0,
            progressTarget: 1,
            unlockedAt: nil,
            isSecret: false
        ),
        
        Achievement(
            id: "12",
            code: "cinderella",
            name: "Cinderella",
            description: "Workout started exactly at 00:00",
            iconName: "shoe.circle.fill",
            category: .timeChallenges,
            rarity: .legendary,
            status: .unlocked,
            progressCurrent: 0,
            progressTarget: 1,
            unlockedAt: nil,
            isSecret: true
        ),
        
        // MARK: Consistency
        
        Achievement(
            id: "13",
            code: "busy_week",
            name: "Busy week",
            description: "7 consecutive workouts",
            iconName: "clock.badge.fill",
            category: .consistency,
            rarity: .epic,
            status: .locked,
            progressCurrent: 4,
            progressTarget: 7,
            unlockedAt: nil,
            isSecret: false
        ),
        
        Achievement(
            id: "14",
            code: "consistent_start",
            name: "Consistent Start",
            description: "Completed weekly goal for the first time",
            iconName: "flame.fill",
            category: .consistency,
            rarity: .common,
            status: .unlocked,
            progressCurrent: 1,
            progressTarget: 1,
            unlockedAt: Date().addingTimeInterval(-86400 * 7),
            isSecret: false
        ),
        
        Achievement(
            id: "15",
            code: "fire_keeper",
            name: "Fire Keeper",
            description: "Maintained a 4-week streak",
            iconName: "flame.circle.fill",
            category: .consistency,
            rarity: .rare,
            status: .unlocked,
            progressCurrent: 4,
            progressTarget: 4,
            unlockedAt: Date().addingTimeInterval(-86400 * 2),
            isSecret: false
        ),
        
        Achievement(
            id: "16",
            code: "unstoppable",
            name: "Unstoppable",
            description: "Maintained a 12-week streak",
            iconName: "bolt.shield.fill",
            category: .consistency,
            rarity: .epic,
            status: .locked,
            progressCurrent: 4,
            progressTarget: 12,
            unlockedAt: nil,
            isSecret: false
        ),
        
        Achievement(
            id: "17",
            code: "comeback",
            name: "Comeback",
            description: "Completed workout after missing a week",
            iconName: "arrow.counterclockwise.circle.fill",
            category: .consistency,
            rarity: .rare,
            status: .locked,
            progressCurrent: 0,
            progressTarget: 1,
            unlockedAt: nil,
            isSecret: false
        ),
        
        Achievement(
            id: "18",
            code: "heavy_month",
            name: "Heavy Month",
            description: "Completed 20 workouts in a month",
            iconName: "calendar.badge.clock",
            category: .consistency,
            rarity: .epic,
            status: .unlocked,
            progressCurrent: 12,
            progressTarget: 20,
            unlockedAt: nil,
            isSecret: false
        ),
        
        // MARK: Social
        
        Achievement(
            id: "19",
            code: "gymbro",
            name: "GymBro",
            description: "Shared at least one workout with a friend",
            iconName: "figure.roll.circle.fill",
            category: .social,
            rarity: .common,
            status: .unlocked,
            progressCurrent: 1,
            progressTarget: 1,
            unlockedAt: Date().addingTimeInterval(-86400 * 6),
            isSecret: false
        ),
        
        Achievement(
            id: "20",
            code: "social_beast",
            name: "Social Beast",
            description: "Shared 10 workouts",
            iconName: "person.2.fill",
            category: .social,
            rarity: .rare,
            status: .unlocked,
            progressCurrent: 3,
            progressTarget: 10,
            unlockedAt: nil,
            isSecret: false
        ),
        
        Achievement(
            id: "21",
            code: "first_like",
            name: "First Like",
            description: "Received first like on a post",
            iconName: "heart.fill",
            category: .social,
            rarity: .common,
            status: .unlocked,
            progressCurrent: 1,
            progressTarget: 1,
            unlockedAt: Date().addingTimeInterval(-86400 * 4),
            isSecret: false
        ),
        
        Achievement(
            id: "22",
            code: "popular_bro",
            name: "Popular Bro",
            description: "Received 50 total likes",
            iconName: "heart.circle.fill",
            category: .social,
            rarity: .epic,
            status: .unlocked,
            progressCurrent: 23,
            progressTarget: 50,
            unlockedAt: nil,
            isSecret: false
        ),
        
        Achievement(
            id: "23",
            code: "explorer",
            name: "Explorer",
            description: "Opened another user’s profile",
            iconName: "person.crop.circle.badge.questionmark",
            category: .social,
            rarity: .common,
            status: .unlocked,
            progressCurrent: 1,
            progressTarget: 1,
            unlockedAt: Date().addingTimeInterval(-86400 * 8),
            isSecret: false
        ),
        
        Achievement(
            id: "24",
            code: "coach_energy",
            name: "Coach Energy",
            description: "Commented on a friend’s workout",
            iconName: "text.bubble.fill",
            category: .social,
            rarity: .common,
            status: .locked,
            progressCurrent: 0,
            progressTarget: 1,
            unlockedAt: nil,
            isSecret: false
        ),
        
        Achievement(
            id: "25",
            code: "pornstar",
            name: "PornStar",
            description: "Your post received 5+ comments",
            iconName: "star.bubble.fill",
            category: .social,
            rarity: .rare,
            status: .locked,
            progressCurrent: 3,
            progressTarget: 5,
            unlockedAt: nil,
            isSecret: false
        ),
        
        // MARK: Special
        
        Achievement(
            id: "26",
            code: "less_words",
            name: "Less words",
            description: "Workout without comments or notes",
            iconName: "microphone.slash.fill",
            category: .special,
            rarity: .common,
            status: .locked,
            progressCurrent: 0,
            progressTarget: 1,
            unlockedAt: nil,
            isSecret: false
        ),
        
        Achievement(
            id: "27",
            code: "whole_body",
            name: "Whor… whole body",
            description: "Targeted 3 different muscle groups in one workout",
            iconName: "figure.strengthtraining.functional.circle.fill",
            category: .special,
            rarity: .rare,
            status: .locked,
            progressCurrent: 2,
            progressTarget: 3,
            unlockedAt: nil,
            isSecret: false
        ),
        
        Achievement(
            id: "28",
            code: "i_know_better",
            name: "I know better",
            description: "Created your own workout",
            iconName: "pencil.and.outline",
            category: .special,
            rarity: .common,
            status: .unlocked,
            progressCurrent: 1,
            progressTarget: 1,
            unlockedAt: Date().addingTimeInterval(-86400 * 12),
            isSecret: false
        )
    ]
    
    // MARK: - Recent Unlocks
    
    static let recentUnlocks: [Achievement] = achievements
        .filter { $0.status == .unlocked }
        .sorted { ($0.unlockedAt ?? .distantPast) > ($1.unlockedAt ?? .distantPast) }
        .prefix(3)
        .map { $0 }
    
    // MARK: - Leaderboard
    
    static let leaderboard: [LeaderboardEntry] = [
        LeaderboardEntry(
            id: "1",
            rank: 1,
            userID: "u1",
            name: "Alexandra",
            username: "gritsaenk0",
            avatarSystemName: "person.fill",
            currentStreakWeeks: 8,
            completedWorkouts: 180,
            isCurrentUser: false,
            isFollowing: true,
            isFriend: true
        ),
        LeaderboardEntry(
            id: "2",
            rank: 2,
            userID: "u2",
            name: "Max",
            username: "maxfit",
            avatarSystemName: "person.fill",
            currentStreakWeeks: 6,
            completedWorkouts: 1,
            isCurrentUser: false,
            isFollowing: false,
            isFriend: true
        ),
        LeaderboardEntry(
            id: "3",
            rank: 3,
            userID: "u3",
            name: "Lena",
            username: "lenastrong",
            avatarSystemName: "person.fill",
            currentStreakWeeks: 5,
            completedWorkouts: 132,
            isCurrentUser: false,
            isFollowing: true,
            isFriend: false
        ),
        LeaderboardEntry(
            id: "4",
            rank: 4,
            userID: "me",
            name: "You",
            username: "you",
            avatarSystemName: "person.fill",
            currentStreakWeeks: 4,
            completedWorkouts: 128,
            isCurrentUser: true,
            isFollowing: true,
            isFriend: true
        )
    ]
    
    static let myRank = MyRank(
        rank: 4,
        currentStreakWeeks: 4,
        completedWorkouts: 128
    )
}

import Foundation
import GymbroNavigation

enum FeedsPeopleMockData {
    
    static let friends: [PersonItem] = [
        PersonItem(
            name: "Alex Petrov",
            username: "@alexp",
            status: "Online",
            subtitle: "Runner • Morning workouts",
            avatarSystemName: "figure.run",
            isFollowing: true,
            isCurrentFriend: true,
            badge: "Athlete",
            workoutsThisMonth: 14
        ),
        PersonItem(
            name: "Maria Ivanova",
            username: "@mariafit",
            status: "Just finished yoga",
            subtitle: "Mobility • Recovery",
            avatarSystemName: "figure.cooldown",
            isFollowing: true,
            isCurrentFriend: true,
            badge: "Athlete",
            workoutsThisMonth: 11
        ),
        PersonItem(
            name: "Coach Daniel",
            username: "@coachdan",
            status: "Available for feedback",
            subtitle: "Strength coach",
            avatarSystemName: "figure.strengthtraining.traditional",
            isFollowing: true,
            isCurrentFriend: true,
            badge: "Coach",
            workoutsThisMonth: 21
        )
    ]
    
    static let discover: [PersonItem] = [
        PersonItem(
            name: "Lena Volkova",
            username: "@lenalifts",
            status: "Leg day energy",
            subtitle: "Strength • Glutes",
            avatarSystemName: "bolt.heart",
            isFollowing: false,
            isCurrentFriend: false,
            badge: "Athlete",
            workoutsThisMonth: 16
        ),
        PersonItem(
            name: "Ivan Smirnov",
            username: "@ivansprint",
            status: "Training for 10K",
            subtitle: "Cardio • Running club",
            avatarSystemName: "figure.run",
            isFollowing: false,
            isCurrentFriend: false,
            badge: "Athlete",
            workoutsThisMonth: 13
        ),
        PersonItem(
            name: "Nina Coach",
            username: "@ninacoach",
            status: "Strength block week 2",
            subtitle: "Coach • Functional training",
            avatarSystemName: "figure.strengthtraining.traditional",
            isFollowing: false,
            isCurrentFriend: false,
            badge: "Coach",
            workoutsThisMonth: 18
        )
    ]
}

import Foundation
import GymbroTypes

enum ChatMockData {
    
    static func messages(for input: ChatSessionInput) -> [ChatMessage] {
        let now = Date()
        
        if input.isDirect {
            let person = input.participants.first!
            return [
                ChatMessage(
                    senderID: person.id,
                    senderName: person.name,
                    senderAvatarSystemName: person.avatarSystemName,
                    sentAt: now.addingTimeInterval(-8600),
                    isMine: false,
                    kind: .text("Hey, are you training today?"),
                    reactions: [ChatReaction(emoji: "🔥", count: 1, isSelectedByMe: false)]
                ),
                ChatMessage(
                    senderID: "me",
                    senderName: "You",
                    senderAvatarSystemName: "person.crop.circle.fill",
                    sentAt: now.addingTimeInterval(-7200),
                    isMine: true,
                    kind: .text("Yes, planning a short strength session in the evening.")
                ),
                ChatMessage(
                    senderID: person.id,
                    senderName: person.name,
                    senderAvatarSystemName: person.avatarSystemName,
                    sentAt: now.addingTimeInterval(-5400),
                    isMine: false,
                    kind: .workout(
                        workoutID: "w_direct_1",
                        title: "Upper Body Strength",
                        subtitle: "Push + shoulders",
                        duration: "45 min",
                        category: "Strength"
                    ),
                    reactions: [
                        ChatReaction(emoji: "💪", count: 2, isSelectedByMe: true),
                        ChatReaction(emoji: "🔥", count: 1, isSelectedByMe: false)
                    ]
                )
            ]
        } else {
            return [
                ChatMessage(
                    senderID: input.participants[0].id,
                    senderName: input.participants[0].name,
                    senderAvatarSystemName: input.participants[0].avatarSystemName,
                    sentAt: now.addingTimeInterval(-12000),
                    isMine: false,
                    kind: .text("Let’s sync on tomorrow’s session.")
                ),
                ChatMessage(
                    senderID: "me",
                    senderName: "You",
                    senderAvatarSystemName: "person.crop.circle.fill",
                    sentAt: now.addingTimeInterval(-9600),
                    isMine: true,
                    kind: .text("I’m in. What time works for everyone?")
                ),
                ChatMessage(
                    senderID: input.participants[1].id,
                    senderName: input.participants[1].name,
                    senderAvatarSystemName: input.participants[1].avatarSystemName,
                    sentAt: now.addingTimeInterval(-8200),
                    isMine: false,
                    kind: .workout(
                        workoutID: "w_group_1",
                        title: "Leg Day Team Session",
                        subtitle: "Squat focus",
                        duration: "60 min",
                        category: "Group Workout"
                    ),
                    reactions: [
                        ChatReaction(emoji: "🔥", count: 3, isSelectedByMe: false),
                        ChatReaction(emoji: "✅", count: 2, isSelectedByMe: true)
                    ]
                )
            ]
        }
    }
    
    static func groupInfo(for input: ChatSessionInput) -> ChatGroupInfo {
        ChatGroupInfo(
            title: input.title,
            description: "Shared training chat for coordination, workout planning, and progress updates.",
            participants: input.participants
        )
    }
}

enum FeedsPeopleMockData {
    
    static let alex = PersonItem(
        id: "01",
        name: "Alex Petrov",
        username: "@alexp",
        status: "Online",
        subtitle: "Runner • Morning workouts",
        avatarSystemName: "figure.run",
        isFollowing: true,
        isCurrentFriend: true,
        badge: "Athlete",
        workoutsThisMonth: 14
    )
    
    static let maria = PersonItem(
        id: "01",
        name: "Maria Ivanova",
        username: "@mariafit",
        status: "Just finished yoga",
        subtitle: "Mobility • Recovery",
        avatarSystemName: "figure.cooldown",
        isFollowing: true,
        isCurrentFriend: true,
        badge: "Athlete",
        workoutsThisMonth: 11
    )
    
    static let coachDaniel = PersonItem(
        id: "01",
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
    
    static let lena = PersonItem(
        id: "01",
        name: "Lena Volkova",
        username: "@lenalifts",
        status: "Leg day energy",
        subtitle: "Strength • Glutes",
        avatarSystemName: "bolt.heart",
        isFollowing: false,
        isCurrentFriend: false,
        badge: "Athlete",
        workoutsThisMonth: 16
    )
    
    static let ivan = PersonItem(
        id: "01",
        name: "Ivan Smirnov",
        username: "@ivansprint",
        status: "Training for 10K",
        subtitle: "Cardio • Running club",
        avatarSystemName: "figure.run",
        isFollowing: false,
        isCurrentFriend: false,
        badge: "Athlete",
        workoutsThisMonth: 13
    )
    
    static let nina = PersonItem(
        id: "01",
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
    
    static let friends: [PersonItem] = [
        alex,
        maria,
        coachDaniel
    ]
    
    static let discover: [PersonItem] = [
        lena,
        ivan,
        nina
    ]
}


//enum FeedsMockData {
//
//    static let communities: [FeedCommunity] = [
//        FeedCommunity(
//            title: "Alex",
//            icon: "person.fill",
//            isSystemImage: true,
//            kind: .directPerson,
//            participants: [FeedsPeopleMockData.alex]
//        ),
//        FeedCommunity(
//            title: "Maria",
//            icon: "person.fill",
//            isSystemImage: true,
//            kind: .directPerson,
//            participants: [FeedsPeopleMockData.maria]
//        ),
//        FeedCommunity(
//            title: "Coach Dan",
//            icon: "person.fill",
//            isSystemImage: true,
//            kind: .directPerson,
//            participants: [FeedsPeopleMockData.coachDaniel]
//        ),
//        FeedCommunity(
//            title: "Lena",
//            icon: "person.fill",
//            isSystemImage: true,
//            kind: .directPerson,
//            participants: [FeedsPeopleMockData.lena]
//        ),
//        FeedCommunity(
//            title: "Gym Squad",
//            icon: "figure.strengthtraining.traditional",
//            isSystemImage: true,
//            kind: .joinedGroup,
//            participants: [
//                FeedsPeopleMockData.alex,
//                FeedsPeopleMockData.maria,
//                FeedsPeopleMockData.coachDaniel
//            ]
//        ),
//        FeedCommunity(
//            title: "Running Club",
//            icon: "figure.run",
//            isSystemImage: true,
//            kind: .joinedGroup,
//            participants: [
//                FeedsPeopleMockData.alex,
//                FeedsPeopleMockData.lena
//            ]
//        ),
//        FeedCommunity(
//            title: "Mobility Team",
//            icon: "figure.cooldown",
//            isSystemImage: true,
//            kind: .joinedGroup,
//            participants: [
//                FeedsPeopleMockData.maria,
//                FeedsPeopleMockData.coachDaniel,
//                FeedsPeopleMockData.lena
//            ]
//        ),
//        FeedCommunity(
//            title: "Weekend Hike",
//            icon: "figure.hiking",
//            isSystemImage: true,
//            kind: .joinedGroup,
//            participants: [
//                FeedsPeopleMockData.alex,
//                FeedsPeopleMockData.maria,
//                FeedsPeopleMockData.lena
//            ]
//        )
//    ]
//}

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

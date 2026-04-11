import Foundation
import GymbroNavigation
import GymbroTypes

@MainActor
final class ChatViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published var messages: [ChatMessage] = []
    @Published var draftText: String = ""
    @Published var isShowingGroupInfo: Bool = false
    @Published var groupInfo: ChatGroupInfo?
    @Published var selectedMessageForQuickReaction: ChatMessage?
    @Published var isShowingQuickReactionPicker: Bool = false
    
    let input: ChatSessionInput
    private let router: any Router
    private let analytics: any AnalyticsService

    init(input: ChatSessionInput, router: any Router, analytics: any AnalyticsService) {
        self.input = input
        self.router = router
        self.analytics = analytics
        loadMockData()
        analytics.track(.screenViewed(screen: .feedsChat))
    }
    
    var title: String {
        input.title
    }
    
    var isDirect: Bool {
        input.isDirect
    }
    
    var isGroup: Bool {
        input.isGroup
    }
    
    var directPerson: ChatParticipant? {
        switch input.presentationStyle {
        case .direct(let person):
            return person
        case .group:
            return nil
        }
    }
    
    func reload() {
        analytics.track(.errorRetryTapped(screen: AnalyticsScreen.feedsChat.rawValue))
        loadMockData()
    }
    
    func didTapBack() {
        router.pop()
    }
    
    func didTapHeaderTitle() {
        switch input.presentationStyle {
        case .direct(let person):
            router.navigate(to: .feedsProfile(title: person.name))
        case .group:
            isShowingGroupInfo = true
            analytics.track(.chatGroupInfoOpened)
        }
    }
    
    func didTapCalendar() {
        switch input.presentationStyle {
        case .direct(let person):
            router.navigate(
                to: .feedsCalendar(
                    context: .directChat(
                        chatID: input.chatID ?? input.title,
                        participantIDs: [person.id],
                        initialPersonID: person.id
                    )
                )
            )
        case .group:
            router.navigate(
                to: .feedsCalendar(
                    context: .groupChat(
                        chatID: input.chatID ?? input.title,
                        groupID: input.title,
                        initialPersonID: nil
                    )
                )
            )
        }
    }
    
    func didTapWorkoutMessage(_ message: ChatMessage) {
        guard case .workout(let workoutID, _, _, _, _) = message.kind else { return }
        analytics.track(.chatWorkoutMessageTapped(workoutId: workoutID))
        print("workout info")
    }
    
    func didLongPressMessage(_ message: ChatMessage) {
        selectedMessageForQuickReaction = message
        isShowingQuickReactionPicker = true
    }
    
    func addQuickReaction(_ emoji: String) {
        guard let message = selectedMessageForQuickReaction else { return }
        analytics.track(.chatReactionAdded(emoji: emoji))
        toggleReaction(emoji, for: message.id)
        hideQuickReactionPicker()
    }

    func hideQuickReactionPicker() {
        isShowingQuickReactionPicker = false
        selectedMessageForQuickReaction = nil
    }
    
    func toggleReaction(_ emoji: String, for messageID: UUID) {
        analytics.track(.chatReactionToggled(emoji: emoji))
        guard let index = messages.firstIndex(where: { $0.id == messageID }) else { return }
        
        var message = messages[index]
        
        if let reactionIndex = message.reactions.firstIndex(where: { $0.emoji == emoji }) {
            let reaction = message.reactions[reactionIndex]
            
            if reaction.isSelectedByMe {
                let newCount = reaction.count - 1
                
                if newCount <= 0 {
                    message.reactions.remove(at: reactionIndex)
                } else {
                    message.reactions[reactionIndex] = ChatReaction(
                        emoji: reaction.emoji,
                        count: newCount,
                        isSelectedByMe: false
                    )
                }
            } else {
                message.reactions[reactionIndex] = ChatReaction(
                    emoji: reaction.emoji,
                    count: reaction.count + 1,
                    isSelectedByMe: true
                )
            }
        } else {
            message.reactions.append(
                ChatReaction(
                    emoji: emoji,
                    count: 1,
                    isSelectedByMe: true
                )
            )
        }
        
        messages[index] = message
    }
    
    func sendMessage() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        messages.append(
            ChatMessage(
                senderID: "me",
                senderName: "You",
                senderAvatarSystemName: "person.crop.circle.fill",
                sentAt: Date(),
                isMine: true,
                kind: .text(text)
            )
        )
        
        analytics.track(.chatMessageSent(isGroup: isGroup))
        draftText = ""
    }
    
    func addPeopleToGroup(_ people: [ChatParticipant]) {
        guard var groupInfo else { return }
        groupInfo.participants.append(contentsOf: people)
        self.groupInfo = groupInfo
        analytics.track(.chatGroupPeopleAdded(count: people.count))
    }
    
    func removePersonFromGroup(_ personID: String) {
        guard var groupInfo else { return }
        groupInfo.participants.removeAll { $0.id == personID }
        self.groupInfo = groupInfo
        analytics.track(.chatGroupParticipantRemoved)
    }
    
    func updateGroupInfo(title: String, description: String) {
        guard var groupInfo else { return }
        groupInfo.title = title
        groupInfo.description = description
        self.groupInfo = groupInfo
        analytics.track(.chatGroupInfoSaved)
    }
    
    func deleteGroup() {
        analytics.track(.chatGroupDeleted)
        router.pop()
    }
    
    var messageSections: [ChatMessageDateSection] {
        let grouped = Dictionary(grouping: messages) { message in
            Calendar.current.startOfDay(for: message.sentAt)
        }
        
        let sortedDates = grouped.keys.sorted()
        
        return sortedDates.map { date in
            ChatMessageDateSection(
                title: dateSeparatorTitle(for: date),
                messages: grouped[date]?.sorted(by: { $0.sentAt < $1.sentAt }) ?? []
            )
        }
    }

    private func dateSeparatorTitle(for date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date).capitalized
        }
    }
    
    private func loadMockData() {
        messages = ChatMockData.messages(for: input)
        if input.isGroup {
            groupInfo = ChatMockData.groupInfo(for: input)
        }
        screenState = .loaded
    }
}

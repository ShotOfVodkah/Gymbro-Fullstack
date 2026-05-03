import Foundation
import GymbroNavigation
import GymbroNetwork
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
    @Published var availablePeopleToAdd: [ChatParticipant] = []
    
    let input: ChatSessionInput
    private let router: any Router
    private let service: any ChatService
    private let analytics: any AnalyticsService
    
    init(
        input: ChatSessionInput,
        router: any Router,
        service: any ChatService,
        analytics: any AnalyticsService
    ) {
        self.input = input
        self.router = router
        self.service = service
        self.analytics = analytics
        reload()
        analytics.track(.screenViewed(screen: .feedsChat))
    }
    
    var title: String {
        groupInfo?.title ?? input.title
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
        Task {
            analytics.track(.errorRetryTapped(screen: AnalyticsScreen.feedsChat.rawValue))
            await loadChat()
        }
    }
    
    private func loadChat() async {
        guard let chatID = input.chatID else {
            screenState = .error
            return
        }
        
        screenState = .loading
        
        do {
            let result = try await service.fetchScreen(chatID: chatID)
            messages = result.messages
            groupInfo = result.groupInfo
            screenState = .loaded
        } catch {
            print("Failed to load chat:", error)
            screenState = .error
        }
    }
    
    func didTapBack() {
        router.pop()
    }
    
    func didTapHeaderTitle() {
        switch input.presentationStyle {
        case .direct(let person):
            guard let userID = Int(person.id) else {
                print("Invalid userID: \(person.id)")
                return
            }
            router.navigate(to: .profileMain(mode: .otherUserProfile(userID: userID)))
            print("\(userID)")
        case .group:
            loadAvailablePeopleToAdd()
            isShowingGroupInfo = true
            analytics.track(.chatGroupInfoOpened)
        }
    }
    
    func didTapCalendar() {
        guard let chatID = input.chatID else { return }
        
        switch input.presentationStyle {
        case .direct(let person):
            router.navigate(
                to: .feedsCalendar(
                    context: .directChat(
                        chatID: chatID,
                        participantIDs: [person.id],
                        initialPersonID: person.id
                    )
                )
            )
            
        case .group:
            router.navigate(
                to: .feedsCalendar(
                    context: .groupChat(
                        chatID: chatID,
                        groupID: chatID,
                        initialPersonID: nil
                    )
                )
            )
        }
    }
    
    func didTapWorkoutMessage(_ message: ChatMessage) {
        guard case .workout(let sessionID, _, _, _, _) = message.kind else { return }
        analytics.track(.chatWorkoutMessageTapped(workoutId: sessionID))
        router.navigate(to: .workoutInfo(id: sessionID, type: .session))
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
    
    func toggleReaction(_ emoji: String, for messageID: String) {
        Task {
            do {
                let updatedReactions = try await service.toggleReaction(messageID: messageID, emoji: emoji)
                guard let index = messages.firstIndex(where: { $0.id == messageID }) else { return }
                messages[index].reactions = updatedReactions
            } catch {
                print("Failed to toggle reaction:", error)
            }
        }
    }
    
    func sendMessage() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let chatID = input.chatID else { return }
        
        Task {
            do {
                let message = try await service.sendText(chatID: chatID, text: text)
                messages.append(message)
                analytics.track(.chatMessageSent(isGroup: isGroup))
                draftText = ""
            } catch {
                print("Failed to send message:", error)
            }
        }
    }
    
    func addPeopleToGroup(_ people: [ChatParticipant]) {
        guard let chatID = input.chatID else { return }
        
        Task {
            do {
                let updated = try await service.addPeople(
                    chatID: chatID,
                    userIDs: people.map(\.id)
                )
                groupInfo = updated
                analytics.track(.chatGroupPeopleAdded(count: people.count))
            } catch {
                print("Failed to add people to group:", error)
            }
        }
    }
    
    func removePersonFromGroup(_ personID: String) {
        guard let chatID = input.chatID else { return }
        
        Task {
            do {
                let updated = try await service.removePerson(
                    chatID: chatID,
                    userID: personID
                )
                groupInfo = updated
                analytics.track(.chatGroupParticipantRemoved)
            } catch {
                print("Failed to remove person from group:", error)
            }
        }
    }
    
    func updateGroupInfo(title: String, description: String) {
        guard let chatID = input.chatID else { return }
        
        Task {
            do {
                let updated = try await service.updateGroup(
                    chatID: chatID,
                    title: title,
                    description: description
                )
                groupInfo = updated
                analytics.track(.chatGroupInfoSaved)
            } catch {
                print("Failed to update group info:", error)
            }
        }
    }
    
    func deleteGroup() {
        guard let chatID = input.chatID else { return }
        
        Task {
            do {
                try await service.deleteGroup(chatID: chatID)
                analytics.track(.chatGroupDeleted)
                router.pop()
            } catch {
                print("Failed to delete group:", error)
            }
        }
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
            return String(localized: "feeds.chat.date.today", bundle: .module)
        } else if calendar.isDateInYesterday(date) {
            return String(localized: "feeds.chat.date.yesterday", bundle: .module)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date).capitalized
        }
    }
    
    func loadAvailablePeopleToAdd() {
        Task {
            do {
                availablePeopleToAdd = try await service.fetchAvailablePeopleToAdd()
            } catch {
                print("Failed to load available people for group:", error)
                availablePeopleToAdd = []
            }
        }
    }
    
    func didTapParticipantProfile(_ participant: ChatParticipant) {
        guard let userID = Int(participant.id) else {
            print("Invalid userID: \(participant.id)")
            return
        }
        
        isShowingGroupInfo = false
        
        if let currentUserID = Int(AppMicroservices.tokens.userId ?? ""), currentUserID == userID {
            router.navigate(to: .profileMain(mode: .myProfile))
        } else {
            router.navigate(to: .profileMain(mode: .otherUserProfile(userID: userID)))
        }
    }
    
    func didTapChallengeMessage(_ message: ChatMessage) {
        guard case .challengeSystem(let challengeID, _, _, _) = message.kind,
              !challengeID.isEmpty else {
            return
        }
        
        router.navigate(to: .challengeDetails(id: challengeID))
    }
}

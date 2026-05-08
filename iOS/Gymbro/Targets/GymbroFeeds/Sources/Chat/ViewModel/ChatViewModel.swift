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
    @Published var room: ChatRoomResponse?
    
    @Published var typingUserIDs: Set<String> = []
    @Published var messageStatuses: [String: ChatMessageLocalStatus] = [:]
    private var realtimeTask: Task<Void, Never>?
    private var typingStopTask: Task<Void, Never>?
    private var lastRefreshAt: Date?
    private var isRefreshing: Bool = false
    
    private var isTypingSent = false

    enum ChatMessageLocalStatus {
        case sending
        case sent
        case failed
    }
    
    let input: ChatSessionInput
    private let router: any Router
    private let service: any ChatService
    private let analytics: any AnalyticsService
    
    private let invalidationCenter: FeedsStateInvalidationCenter
    
    init(
        input: ChatSessionInput,
        router: any Router,
        service: any ChatService,
        analytics: any AnalyticsService,
        invalidationCenter: FeedsStateInvalidationCenter? = nil
    ) {
        self.input = input
        self.router = router
        self.service = service
        self.analytics = analytics
        self.invalidationCenter = invalidationCenter ?? FeedsStateInvalidationCenter.shared
        
        reload()
        analytics.track(.screenViewed(screen: .feedsChat))
    }
    
    deinit {
        realtimeTask?.cancel()
        typingStopTask?.cancel()
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

    func onAppear() {
        Task {
            await refreshIfStale()
        }
    }
    
    private func loadChat() async {
        guard let chatID = input.chatID else {
            screenState = .error
            return
        }

        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        
        screenState = .loading
        
        do {
            let result = try await service.fetchScreen(chatID: chatID)
            room = result.room
            messages = result.messages
            groupInfo = result.groupInfo
            screenState = .loaded
            lastRefreshAt = Date()
            
            startRealtime()
            markLastMessageAsRead()
        } catch {
            print("Failed to load chat:", error)
            screenState = .error
        }
    }

    private func refreshIfStale(maxAgeSeconds: TimeInterval = 15) async {
        let age = Date().timeIntervalSince(lastRefreshAt ?? .distantPast)
        guard age > maxAgeSeconds else { return }
        await loadChat()
    }
    
    func didTapBack() {
        invalidationCenter.invalidate(.communitiesChanged)
        router.pop()
    }
    
    func didTapHeaderTitle() {
        switch input.presentationStyle {
        case .direct(let person):
            let targetPerson = resolvedDirectParticipant(fallback: person)
            
            guard let userID = Int(targetPerson.id) else {
                print("Invalid userID: \(targetPerson.id)")
                return
            }
            
            router.navigate(to: .profileMain(mode: .otherUserProfile(userID: userID)))
            
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
        draftText = ""
        
        isTypingSent = false
        Task {
            try? await service.stopTyping(chatID: chatID)
        }
        
        Task {
            do {
                let message = try await service.sendText(chatID: chatID, text: text)
                upsertMessage(message)
                messageStatuses[message.id] = .sent
                analytics.track(.chatMessageSent(isGroup: isGroup))
                invalidationCenter.invalidate(.chatChanged(chatID: chatID))
                markLastMessageAsRead()
            } catch {
                print("Failed to send message:", error)
                draftText = text
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
                invalidationCenter.invalidate(.chatChanged(chatID: chatID))
                invalidationCenter.invalidate(.communitiesChanged)
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
                
                invalidationCenter.invalidate(.chatChanged(chatID: chatID))
                invalidationCenter.invalidate(.communitiesChanged)
                analytics.track(.chatGroupParticipantRemoved)
                
                if personID == AppMicroservices.tokens.userId {
                    isShowingGroupInfo = false
                    router.pop()
                    return
                }
                
                groupInfo = updated
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
                isShowingGroupInfo = false
                analytics.track(.chatGroupInfoSaved)
                invalidationCenter.invalidate(.communitiesChanged)
                invalidationCenter.invalidate(.chatChanged(chatID: chatID))
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
                invalidationCenter.invalidate(.communitiesChanged)
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
    
    private var currentUserID: String {
        AppMicroservices.tokens.userId ?? ""
    }
    
    private func startRealtime() {
        guard let chatID = input.chatID else { return }
        realtimeTask?.cancel()
        realtimeTask = Task { [weak self] in
            guard let self else { return }

            do {
                for try await event in service.streamEvents(chatID: chatID) {
                    await self.handleRealtimeEvent(event)
                }
            } catch is CancellationError {
                print("⚠️ REALTIME CANCELLED")
            } catch {
                print("❌ Chat realtime failed:", error)
            }
        }
    }
    
    private func handleRealtimeEvent(_ event: ChatRealtimeEventResponse) async {
        switch event.type {
        case "connected":
            break

        case "new_message":
            if case .message(let response) = event.payload {
                let message = ChatMessage(
                    response: response,
                    currentUserID: currentUserID
                )
                upsertMessage(message)
                markLastMessageAsRead()
            } else {
                print("❌ new_message payload is NOT message:", event.payload as Any)
            }

        case "reaction_updated":
            if case .reactionUpdated(let update) = event.payload {
                updateMessageReactions(
                    messageID: update.message_id,
                    reactions: update.reactions.map(ChatReaction.init(response:))
                )
            }

        case "member_added", "member_removed":
            if case .room(let room) = event.payload {
                groupInfo = ChatGroupInfo(response: room)
                invalidationCenter.invalidate(.communitiesChanged)
            }

        case "read_updated":
            if case .read(let read) = event.payload {
                handleReadUpdated(read)
            }

        case "typing_started":
            if case .typing(let typing) = event.payload,
               typing.user_id != currentUserID {
                typingUserIDs.insert(typing.user_id)
            }

        case "typing_stopped":
            if case .typing(let typing) = event.payload {
                typingUserIDs.remove(typing.user_id)
            }

        default:
            break
        }
    }
    
    private func upsertMessage(_ message: ChatMessage) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index] = message
        } else {
            messages.append(message)
        }

        messageStatuses[message.id] = .sent
        invalidationCenter.invalidate(.chatChanged(chatID: input.chatID))
    }
    
    private func markLastMessageAsRead() {
        guard let chatID = input.chatID else { return }
        let lastID = messages.last?.id

        Task {
            do {
                try await service.markRead(chatID: chatID, lastReadMessageID: lastID)
            } catch {
                print("Failed to mark chat read:", error)
            }
        }
    }
    
    private func updateMessageReactions(
        messageID: String,
        reactions: [ChatReaction]
    ) {
        guard let index = messages.firstIndex(where: { $0.id == messageID }) else {
            return
        }
        
        messages[index].reactions = reactions
        invalidationCenter.invalidate(.chatChanged(chatID: input.chatID))
    }

    private func handleReadUpdated(_ read: ChatReadResponse) {
        invalidationCenter.invalidate(.communitiesChanged)
    }
    
    func didChangeDraftText(_ text: String) {
        draftText = text
        guard let chatID = input.chatID else { return }

        typingStopTask?.cancel()

        if !isTypingSent {
            isTypingSent = true
            Task {
                try? await service.startTyping(chatID: chatID)
            }
        }

        typingStopTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard let self else { return }

            self.isTypingSent = false
            try? await self.service.stopTyping(chatID: chatID)
        }
    }
    
    private func resolvedDirectParticipant(
        fallback person: ChatParticipant
    ) -> ChatParticipant {
        guard person.id == currentUserID else {
            return person
        }

        if let other = room?.participants.first(where: { $0.id != currentUserID }) {
            return ChatParticipant(response: other)
        }

        return person
    }
}

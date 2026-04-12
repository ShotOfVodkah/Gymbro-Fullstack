import Foundation
import GymbroTypes

public final class FeedsClient {
    
    public init(client: NetworkClient) {
        self.client = client
    }
    
    private let client: NetworkClient
    
    public func fetchFeed() async throws -> [FeedPostItemResponse] {
        let _ = try requireUserId()
        
        return try await client.request(
            method: .GET,
            path: "feed",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [FeedPostItemResponse].self
        )
    }
    
    public func fetchCommunities() async throws -> [FeedCommunityItemResponse] {
        try await client.request(
            method: .GET,
            path: "communities",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [FeedCommunityItemResponse].self
        )
    }
    
    public func fetchCalendarPeople(
        context: CalendarContext
    ) async throws -> [CalendarPersonResponse] {
        try await client.request(
            method: .GET,
            path: "calendar/people",
            queryItems: calendarPeopleQueryItems(for: context),
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [CalendarPersonResponse].self
        )
    }

    public func fetchCalendarMonth(
        context: CalendarContext,
        month: Date,
        selectedPersonID: String?
    ) async throws -> CalendarMonthResponse {
        try await client.request(
            method: .GET,
            path: "calendar/month",
            queryItems: calendarMonthQueryItems(
                for: context,
                month: month,
                selectedPersonID: selectedPersonID
            ),
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: CalendarMonthResponse.self
        )
    }
    
    public func fetchFriends() async throws -> [PersonItemResponse] {
        try await client.request(
            method: .GET,
            path: "people/friends",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [PersonItemResponse].self
        )
    }

    public func fetchFollowing() async throws -> [PersonItemResponse] {
        try await client.request(
            method: .GET,
            path: "people/following",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [PersonItemResponse].self
        )
    }

    public func fetchDiscoverPeople(query: String? = nil) async throws -> [PersonItemResponse] {
        let queryItems: [URLQueryItem]? = {
            guard let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return nil
            }
            return [URLQueryItem(name: "q", value: query)]
        }()

        return try await client.request(
            method: .GET,
            path: "people/discover",
            queryItems: queryItems,
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [PersonItemResponse].self
        )
    }

    public func fetchPerson(id: String) async throws -> PersonItemResponse {
        try await client.request(
            method: .GET,
            path: "people/\(id)",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: PersonItemResponse.self
        )
    }

    public func followPerson(id: String) async throws {
        try await client.requestVoid(
            method: .POST,
            path: "people/\(id)/follow",
            body: Optional<EmptyBody>.none,
            requiresAuth: true
        )
    }

    public func unfollowPerson(id: String) async throws {
        try await client.requestVoid(
            method: .DELETE,
            path: "people/\(id)/follow",
            body: Optional<EmptyBody>.none,
            requiresAuth: true
        )
    }
    
    public func createDirectChat(participantID: String) async throws -> ChatRoomResponse {
        try await client.request(
            method: .POST,
            path: "chats/direct",
            body: CreateDirectChatRequest(participant_id: participantID),
            requiresAuth: true,
            responseType: ChatRoomResponse.self
        )
    }

    public func createGroupChat(
        title: String,
        description: String,
        participantIDs: [String]
    ) async throws -> ChatRoomResponse {
        try await client.request(
            method: .POST,
            path: "chats/group",
            body: CreateGroupChatRequest(
                title: title,
                description: description,
                participant_ids: participantIDs
            ),
            requiresAuth: true,
            responseType: ChatRoomResponse.self
        )
    }
    
    public func fetchChat(id: String) async throws -> ChatRoomResponse {
        try await client.request(
            method: .GET,
            path: "chats/\(id)",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: ChatRoomResponse.self
        )
    }

    public func fetchChatMessages(id: String) async throws -> [ChatMessageResponse] {
        try await client.request(
            method: .GET,
            path: "chats/\(id)/messages",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [ChatMessageResponse].self
        )
    }
    
    public func sendTextMessage(chatID: String, text: String) async throws -> ChatMessageResponse {
        try await client.request(
            method: .POST,
            path: "chats/\(chatID)/messages",
            body: SendChatMessageRequest(
                kind: "text",
                text: text,
                session_id: nil
            ),
            requiresAuth: true,
            responseType: ChatMessageResponse.self
        )
    }

    public func sendWorkoutMessage(
        chatID: String,
        sessionID: String?
    ) async throws -> ChatMessageResponse {
        try await client.request(
            method: .POST,
            path: "chats/\(chatID)/messages",
            body: SendChatMessageRequest(
                kind: "workout",
                text: nil,
                session_id: sessionID
            ),
            requiresAuth: true,
            responseType: ChatMessageResponse.self
        )
    }
    
    public func toggleMessageReaction(messageID: String, emoji: String) async throws -> [ChatReactionResponse] {
        try await client.request(
            method: .POST,
            path: "messages/\(messageID)/reactions",
            body: ToggleReactionRequest(emoji: emoji),
            requiresAuth: true,
            responseType: [ChatReactionResponse].self
        )
    }
    
    public func updateGroupChat(chatID: String, title: String, description: String) async throws -> ChatRoomResponse {
        try await client.request(
            method: .PATCH,
            path: "chats/\(chatID)",
            body: UpdateGroupChatRequest(title: title, description: description),
            requiresAuth: true,
            responseType: ChatRoomResponse.self
        )
    }

    public func addPeopleToGroup(chatID: String, userIDs: [String]) async throws -> ChatRoomResponse {
        try await client.request(
            method: .POST,
            path: "chats/\(chatID)/members",
            body: AddChatMembersRequest(user_ids: userIDs),
            requiresAuth: true,
            responseType: ChatRoomResponse.self
        )
    }

    public func removePersonFromGroup(chatID: String, userID: String) async throws -> ChatRoomResponse {
        try await client.request(
            method: .DELETE,
            path: "chats/\(chatID)/members/\(userID)",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: ChatRoomResponse.self
        )
    }

    public func deleteGroupChat(chatID: String) async throws {
        try await client.requestVoid(
            method: .DELETE,
            path: "chats/\(chatID)",
            body: Optional<EmptyBody>.none,
            requiresAuth: true
        )
    }
    
    private func requireUserId() throws -> String {
        guard let userId = AppMicroservices.tokens.userId, !userId.isEmpty else {
            throw NetworkError.unauthorized
        }
        return userId
    }
    
    private func calendarPeopleQueryItems(for context: CalendarContext) -> [URLQueryItem] {
        switch context {
        case .mine:
            return [
                URLQueryItem(name: "context", value: "mine")
            ]

        case .person(let personID, _):
            return [
                URLQueryItem(name: "context", value: "person"),
                URLQueryItem(name: "person_id", value: personID)
            ]

        case .directChat(let chatID, _, _):
            return [
                URLQueryItem(name: "context", value: "direct_chat"),
                URLQueryItem(name: "chat_id", value: chatID)
            ]

        case .groupChat(let chatID, let groupID, _):
            return [
                URLQueryItem(name: "context", value: "group_chat"),
                URLQueryItem(name: "chat_id", value: chatID),
                URLQueryItem(name: "group_id", value: groupID)
            ]
        }
    }
    
    private func calendarMonthQueryItems(
        for context: CalendarContext,
        month: Date,
        selectedPersonID: String?
    ) -> [URLQueryItem] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"

        var items = [
            URLQueryItem(name: "month", value: formatter.string(from: month))
        ]

        switch context {
        case .mine:
            items.append(URLQueryItem(name: "context", value: "mine"))

        case .person(let personID, _):
            items.append(URLQueryItem(name: "context", value: "person"))
            items.append(URLQueryItem(name: "person_id", value: personID))

        case .directChat(let chatID, _, _):
            items.append(URLQueryItem(name: "context", value: "direct_chat"))
            items.append(URLQueryItem(name: "chat_id", value: chatID))

        case .groupChat(let chatID, let groupID, _):
            items.append(URLQueryItem(name: "context", value: "group_chat"))
            items.append(URLQueryItem(name: "chat_id", value: chatID))
            items.append(URLQueryItem(name: "group_id", value: groupID))
        }

        if let selectedPersonID {
            items.append(URLQueryItem(name: "selected_person_id", value: selectedPersonID))
        }

        return items
    }
}

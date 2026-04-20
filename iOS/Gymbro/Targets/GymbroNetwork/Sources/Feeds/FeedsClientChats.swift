import Foundation
import GymbroTypes

public extension FeedsClient {
    
    func createDirectChat(participantID: String) async throws -> ChatRoomResponse {
        try await client.request(
            method: .POST,
            path: "chats/direct",
            body: CreateDirectChatRequest(participant_id: participantID),
            requiresAuth: true,
            responseType: ChatRoomResponse.self
        )
    }

    func createGroupChat(
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
    
    func fetchChat(id: String) async throws -> ChatRoomResponse {
        try await client.request(
            method: .GET,
            path: "chats/\(id)",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: ChatRoomResponse.self
        )
    }

    func fetchChatMessages(id: String) async throws -> [ChatMessageResponse] {
        try await client.request(
            method: .GET,
            path: "chats/\(id)/messages",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [ChatMessageResponse].self
        )
    }
    
    func sendTextMessage(chatID: String, text: String) async throws -> ChatMessageResponse {
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

    func sendWorkoutMessage(
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
    
    func toggleMessageReaction(messageID: String, emoji: String) async throws -> [ChatReactionResponse] {
        try await client.request(
            method: .POST,
            path: "messages/\(messageID)/reactions",
            body: ToggleReactionRequest(emoji: emoji),
            requiresAuth: true,
            responseType: [ChatReactionResponse].self
        )
    }
    
    func updateGroupChat(chatID: String, title: String, description: String) async throws -> ChatRoomResponse {
        try await client.request(
            method: .PATCH,
            path: "chats/\(chatID)",
            body: UpdateGroupChatRequest(title: title, description: description),
            requiresAuth: true,
            responseType: ChatRoomResponse.self
        )
    }

    func addPeopleToGroup(chatID: String, userIDs: [String]) async throws -> ChatRoomResponse {
        try await client.request(
            method: .POST,
            path: "chats/\(chatID)/members",
            body: AddChatMembersRequest(user_ids: userIDs),
            requiresAuth: true,
            responseType: ChatRoomResponse.self
        )
    }

    func removePersonFromGroup(chatID: String, userID: String) async throws -> ChatRoomResponse {
        try await client.request(
            method: .DELETE,
            path: "chats/\(chatID)/members/\(userID)",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: ChatRoomResponse.self
        )
    }

    func deleteGroupChat(chatID: String) async throws {
        try await client.requestVoid(
            method: .DELETE,
            path: "chats/\(chatID)",
            body: Optional<EmptyBody>.none,
            requiresAuth: true
        )
    }
}

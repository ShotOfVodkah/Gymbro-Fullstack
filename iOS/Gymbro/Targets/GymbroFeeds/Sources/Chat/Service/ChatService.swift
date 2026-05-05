import Foundation
import GymbroTypes
import GymbroNetwork

struct ChatScreenData {
    let room: ChatRoomResponse
    let messages: [ChatMessage]
    let groupInfo: ChatGroupInfo?
}

protocol ChatService {
    func fetchScreen(chatID: String) async throws -> ChatScreenData
    func sendText(chatID: String, text: String) async throws -> ChatMessage
    func toggleReaction(messageID: String, emoji: String) async throws -> [ChatReaction]
    func updateGroup(chatID: String, title: String, description: String) async throws -> ChatGroupInfo
    func addPeople(chatID: String, userIDs: [String]) async throws -> ChatGroupInfo
    func removePerson(chatID: String, userID: String) async throws -> ChatGroupInfo
    func deleteGroup(chatID: String) async throws
    func fetchAvailablePeopleToAdd() async throws -> [ChatParticipant]
    
    func markRead(chatID: String, lastReadMessageID: String?) async throws
    func startTyping(chatID: String) async throws
    func stopTyping(chatID: String) async throws
    func streamEvents(chatID: String) -> AsyncThrowingStream<ChatRealtimeEventResponse, Error>
}

final class ChatServiceImpl: ChatService {
    
    init(client: FeedsClient, realtimeClient: FeedsChatRealtimeClient) {
        self.client = client
        self.realtimeClient = realtimeClient
    }
    
    func fetchScreen(chatID: String) async throws -> ChatScreenData {
        async let roomResponse = client.fetchChat(id: chatID)
        async let messagesResponse = client.fetchChatMessages(id: chatID)
        
        let room = try await roomResponse
        let messages = try await messagesResponse.map(ChatMessage.init(response:))
        
        return ChatScreenData(
            room: room,
            messages: messages,
            groupInfo: room.kind == "joined_group" ? ChatGroupInfo(response: room) : nil
        )
    }
    
    func sendText(chatID: String, text: String) async throws -> ChatMessage {
        let response = try await client.sendTextMessage(chatID: chatID, text: text)
        return ChatMessage(response: response)
    }
    
    func toggleReaction(messageID: String, emoji: String) async throws -> [ChatReaction] {
        let response = try await client.toggleMessageReaction(messageID: messageID, emoji: emoji)
        return response.map(ChatReaction.init(response:))
    }
    
    func updateGroup(chatID: String, title: String, description: String) async throws -> ChatGroupInfo {
        let response = try await client.updateGroupChat(chatID: chatID, title: title, description: description)
        return ChatGroupInfo(response: response)
    }
    
    func addPeople(chatID: String, userIDs: [String]) async throws -> ChatGroupInfo {
        let response = try await client.addPeopleToGroup(chatID: chatID, userIDs: userIDs)
        return ChatGroupInfo(response: response)
    }
    
    func removePerson(chatID: String, userID: String) async throws -> ChatGroupInfo {
        let response = try await client.removePersonFromGroup(chatID: chatID, userID: userID)
        return ChatGroupInfo(response: response)
    }
    
    func deleteGroup(chatID: String) async throws {
        try await client.deleteGroupChat(chatID: chatID)
    }
    
    func markRead(chatID: String, lastReadMessageID: String?) async throws {
        _ = try await client.markChatRead(chatID: chatID, lastReadMessageID: lastReadMessageID)
    }

    func startTyping(chatID: String) async throws {
        try await client.startTyping(chatID: chatID)
    }

    func stopTyping(chatID: String) async throws {
        try await client.stopTyping(chatID: chatID)
    }

    func streamEvents(chatID: String) -> AsyncThrowingStream<ChatRealtimeEventResponse, Error> {
        realtimeClient.stream(chatID: chatID)
    }
    
    func fetchAvailablePeopleToAdd() async throws -> [ChatParticipant] {
        async let friendsResponse = client.fetchFriends()
        async let followingResponse = client.fetchFollowing()
        async let discoverResponse = client.fetchDiscoverPeople()
        
        let friends = try await friendsResponse.map(PersonItem.init(response:))
        let following = try await followingResponse.map(PersonItem.init(response:))
        let discover = try await discoverResponse.map(PersonItem.init(response:))
        
        let combined = friends + following + discover
        
        var seen = Set<String>()
        let unique = combined.filter {
            guard !seen.contains($0.id) else { return false }
            seen.insert($0.id)
            return true
        }
        
        return unique.map {
            ChatParticipant(
                id: $0.id,
                name: $0.name,
                avatarSystemName: $0.avatarSystemName
            )
        }
    }
    
    private let client: FeedsClient
    private let realtimeClient: FeedsChatRealtimeClient
}

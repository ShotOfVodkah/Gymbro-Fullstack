import Foundation
import GymbroNetwork
import GymbroTypes

protocol WorkoutShareService {
    func fetchRecipientDestinations() async throws -> WorkoutShareRecipientData
    func submitShare(sessionID: String, targets: ResolvedShareTargets, caption: String, location: String?) async throws -> ShareWorkoutResponse
}

struct WorkoutShareRecipientData {
    let chats: [ShareDestination]
    let friends: [ShareDestination]
}

final class WorkoutShareServiceImpl: WorkoutShareService {
    init(
        feedsClient: any FeedsClientProtocol,
        perksEvents: any PerksEventTrackingService
    ) {
        self.feedsClient = feedsClient
        self.perksEvents = perksEvents
    }

    func fetchRecipientDestinations() async throws -> WorkoutShareRecipientData {
        async let communitiesResponse = feedsClient.fetchCommunities()
        async let friendsResponse = feedsClient.fetchFriends()

        let communities = try await communitiesResponse
        let friends = try await friendsResponse

        let chatDestinations: [ShareDestination] = communities.map { item in
            let kind: ShareChatKind = item.kind == "direct" ? .direct : .group
            return .existingChat(
                id: item.id,
                title: item.display_title,
                kind: kind
            )
        }

        let friendDestinations: [ShareDestination] = friends.map {
            .directUser(
                id: $0.id,
                name: $0.name,
                username: $0.username
            )
        }

        return WorkoutShareRecipientData(
            chats: chatDestinations,
            friends: friendDestinations
        )
    }
    
    func submitShare(sessionID: String, targets: ResolvedShareTargets, caption: String, location: String?) async throws -> ShareWorkoutResponse {
        let response = try await feedsClient.shareWorkout(
            sessionID: sessionID,
            publishToFeed: targets.publishToFeed,
            existingChatIDs: targets.existingChatIDs,
            directUserIDs: targets.directUserIDs,
            description: caption,
            location: location
        )
        await perksEvents.trackWorkoutShared()
        return response
    }

    private let feedsClient: any FeedsClientProtocol
    private let perksEvents: any PerksEventTrackingService
}

import SwiftUI
import GymbroTypes

struct WorkoutShareRecipientsStepView: View {
    @ObservedObject var viewModel: WorkoutShareViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            WorkoutShareSectionCard(title: "Post to Feed") {
                WorkoutShareSelectableRow(
                    title: "My Feed",
                    subtitle: "Publish workout to feed",
                    isSelected: viewModel.draft.publishToFeed,
                    iconName: "sparkles.rectangle.stack.fill",
                    iconTint: .appPurple,
                    action: { viewModel.togglePublishToFeed() }
                )
                .accessibilityIdentifier("feeds.workoutShare.option.feed")
            }
            
            WorkoutShareSectionCard(title: "Existing Chats") {
                if viewModel.availableChatDestinations.isEmpty {
                    WorkoutShareEmptyStateRow(text: "No chats yet")
                } else {
                    VStack(spacing: 10) {
                        ForEach(viewModel.availableChatDestinations, id: \.id) { destination in
                            WorkoutShareSelectableRow(
                                title: viewModel.destinationTitle(destination),
                                subtitle: viewModel.destinationSubtitle(destination),
                                isSelected: viewModel.isSelected(destination),
                                iconName: iconName(for: destination),
                                iconTint: .appPurple,
                                action: { viewModel.toggleDestination(destination) }
                            )
                        }
                    }
                }
            }
            
            WorkoutShareSectionCard(title: "Friends") {
                if viewModel.availableFriendDestinations.isEmpty {
                    WorkoutShareEmptyStateRow(text: "No friends found")
                } else {
                    VStack(spacing: 10) {
                        ForEach(viewModel.availableFriendDestinations, id: \.id) { destination in
                            WorkoutShareSelectableRow(
                                title: viewModel.destinationTitle(destination),
                                subtitle: viewModel.destinationSubtitle(destination),
                                isSelected: viewModel.isSelected(destination),
                                iconName: "person.fill",
                                iconTint: .appPurple,
                                action: { viewModel.toggleDestination(destination) }
                            )
                        }
                    }
                }
            }
        }
    }
    
    private func iconName(for destination: ShareDestination) -> String {
        switch destination {
        case .existingChat(_, _, let kind):
            switch kind {
            case .direct:
                return "person.fill"
            case .group:
                return "person.3.fill"
            }
        case .directUser:
            return "person.fill"
        case .feed:
            return "sparkles.rectangle.stack.fill"
        case .community:
            return "person.3.fill"
        }
    }
}

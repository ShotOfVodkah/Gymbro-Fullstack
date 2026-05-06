import SwiftUI
import GymbroCommonUI
import GymbroTypes

struct WorkoutShareSuccessView: View {
    let summary: WorkoutShareDeliverySummary
    let onDoneTap: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.appPurple.opacity(0.9), Color.purple.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 84, height: 84)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                )

            Text("Workout shared")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            Text(successSubtitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            WorkoutShareDeliverySummaryCard(summary: summary)

            Spacer()

            AppButton("Done", size: .xl, action: onDoneTap, wrapContent: false)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            UITestMarker(id: "feeds.workoutShare.success")
        }
    }

    private var successSubtitle: String {
        if summary.didCreateFeedPost && summary.deliveredChatsCount > 0 {
            return "Your workout was published to feed and delivered to selected chats."
        } else if summary.didCreateFeedPost {
            return "Your workout was published to feed."
        } else if summary.deliveredChatsCount > 0 {
            return "Your workout was delivered to selected chats."
        } else {
            return "Your workout share was completed."
        }
    }
}

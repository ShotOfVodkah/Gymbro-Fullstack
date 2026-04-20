import SwiftUI
import GymbroTypes

struct WorkoutShareDeliverySummaryCard: View {
    let summary: WorkoutShareDeliverySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Delivery summary")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.72))
                .textCase(.uppercase)

            VStack(spacing: 10) {
                if summary.didCreateFeedPost {
                    summaryRow(
                        icon: "sparkles.rectangle.stack.fill",
                        title: "Published to feed",
                        value: nil
                    )
                }
                
                if summary.deliveredChatsCount > 0 {
                    summaryRow(
                        icon: "paperplane.fill",
                        title: "Delivered chats",
                        value: "\(summary.deliveredChatsCount)"
                    )
                }

                if summary.createdChatsCount > 0 {
                    summaryRow(
                        icon: "person.badge.plus",
                        title: "Created direct chats",
                        value: "\(summary.createdChatsCount)"
                    )
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    private func summaryRow(icon: String, title: String, value: String?) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.appPurple.opacity(0.58))
                .frame(width: 38, height: 38)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.white)
                )

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)

            Spacer()

            if let value {
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.appPurple.opacity(0.58))
                    )
            } else {
                ZStack {
                    Circle()
                        .fill(Color.appPurple.opacity(0.58))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.white)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

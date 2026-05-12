import Foundation
import SwiftUI
import GymbroTypes

struct ChallengeActivityTimelineView: View {
    
    let activity: [ChallengeActivityModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionTitle(
                String(localized: "challenges.details.activity.title", bundle: .module),
                String(localized: "challenges.details.activity.subtitle", bundle: .module)
            )
            
            VStack(spacing: 0) {
                ForEach(activity) { item in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(actionColor(item.action))
                                .frame(width: 10, height: 10)
                            
                            Rectangle()
                                .fill(.white.opacity(0.08))
                                .frame(width: 2, height: 44)
                        }
                        .padding(.top, 5)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activityTitle(item))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("\(item.value) \(item.unit.rawValue) • \(item.createdAt.formatted(date: .omitted, time: .shortened))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.52))
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(14)
            .background(baseCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }
    
    private func activityTitle(_ item: ChallengeActivityModel) -> String {
        switch item.action {
        case .completedWorkout:
            return String(
                format: String(localized: "challenges.activity.user_completed_workout", bundle: .module),
                locale: .current,
                item.userName
            )
        case .joinedChallenge:
            return String(
                format: String(localized: "challenges.activity.user_joined", bundle: .module),
                locale: .current,
                item.userName
            )
        case .completedChallenge:
            return String(localized: "challenges.activity.completed", bundle: .module)
        case .failedChallenge:
            return String(localized: "challenges.activity.failed", bundle: .module)
        }
    }
    
    private func actionColor(_ action: ChallengeActivityAction) -> Color {
        switch action {
        case .completedWorkout: return .orange
        case .joinedChallenge: return .blue
        case .completedChallenge: return .green
        case .failedChallenge: return .red
        }
    }
}

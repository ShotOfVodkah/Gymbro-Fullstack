import SwiftUI
import GymbroTypes

struct ChallengeActivityTimelineView: View {
    
    let activity: [ChallengeActivityModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionTitle("Activity", "Recent team actions")
            
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
            return "\(item.userName) completed a workout"
        case .joinedChallenge:
            return "\(item.userName) joined the challenge"
        case .completedChallenge:
            return "Challenge completed"
        case .failedChallenge:
            return "Challenge failed"
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

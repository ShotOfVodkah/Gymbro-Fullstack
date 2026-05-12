import SwiftUI
import GymbroTypes

struct ChallengeDifficultyBadgeView: View {
    
    let difficulty: ChallengeDifficulty
    
    private var title: String {
        switch difficulty {
        case .easy:
            return String(localized: "challenges.difficulty.easy", bundle: .module)
        case .medium:
            return String(localized: "challenges.difficulty.medium", bundle: .module)
        case .hard:
            return String(localized: "challenges.difficulty.hard", bundle: .module)
        case .legendary:
            return String(localized: "challenges.difficulty.legendary", bundle: .module)
        }
    }
    
    private var iconName: String {
        switch difficulty {
        case .easy: return "leaf.fill"
        case .medium: return "bolt.fill"
        case .hard: return "flame.fill"
        case .legendary: return "crown.fill"
        }
    }
    
    private var color: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .legendary: return .purple
        }
    }
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: iconName)
                .font(.system(size: 10, weight: .bold))
            
            Text(title)
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
        )
        .overlay(
            Capsule()
                .stroke(color.opacity(0.24), lineWidth: 1)
        )
    }
}

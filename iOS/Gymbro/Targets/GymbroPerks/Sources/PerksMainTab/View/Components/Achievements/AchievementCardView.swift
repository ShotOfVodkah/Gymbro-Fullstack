import SwiftUI
import GymbroTypes

struct AchievementCardView: View {
    
    let achievement: Achievement
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            GeometryReader { proxy in
                let side = proxy.size.width
                
                VStack(spacing: 10) {
                    Spacer(minLength: 0)
                    
                    Image(systemName: achievement.iconName)
                        .font(.system(size: side * 0.28, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: side * 0.48, height: side * 0.48)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.16))
                        )
                    
                    Text(achievement.name)
                        .font(.system(size: max(13, side * 0.135), weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.58)
                        .frame(maxWidth: .infinity)
                    
                    Spacer(minLength: 0)
                }
                .padding(10)
                .frame(width: side, height: side)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(cardBorder)
                .opacity(achievement.isUnlocked ? 1 : 0.52)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("perks.achievement.card.\(achievement.code)")
    }
    
    private var cardBackground: some View {
        LinearGradient(
            colors: backgroundColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        achievement.isUnlocked ? rarityColor.opacity(0.85) : Color.white.opacity(0.16),
                        Color.white.opacity(0.18),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: achievement.isUnlocked ? 1.2 : 1
            )
    }
    
    private var rarityColor: Color {
        switch achievement.rarity {
        case .common:
            return .green
        case .rare:
            return .blue
        case .epic:
            return .orange
        case .legendary:
            return .yellow
        }
    }
    
    private var backgroundColors: [Color] {
        let base = Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255)
        
        if !achievement.isUnlocked {
            return [
                Color(red: 32 / 255, green: 34 / 255, blue: 42 / 255),
                base
            ]
        }
        
        switch achievement.rarity {
        case .common:
            return [
                Color.green,
                base
            ]
        case .rare:
            return [
                Color.blue,
                base
            ]
        case .epic:
            return [
                Color.orange,
                base
            ]
        case .legendary:
            return [
                Color.yellow,
                base
            ]
        }
    }
}

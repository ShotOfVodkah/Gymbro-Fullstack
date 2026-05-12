import SwiftUI
import GymbroCommonUI
import GymbroTypes

struct AchievementExpandedCardView: View {
    
    let achievement: Achievement
    let onClose: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 68, height: 68)
                    
                    Image(systemName: achievement.iconName)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("perks.achievement.expanded.close")
            }
            
            VStack(alignment: .leading, spacing: 7) {
                Text(achievement.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                
                Text(achievement.rarity.title.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.68))
            }
            
            Text(achievement.description)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
            
            progressView
            
            statusView
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(cardBorder)
        .shadow(color: rarityColor.opacity(0.35), radius: 22, x: 0, y: 14)
        .padding(.horizontal, 10)
        .overlay(alignment: .topLeading) {
            UITestMarker(id: "perks.achievement.expanded")
        }
    }
    
    private var progressView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(String(localized: "perks.achievement.progress", bundle: .module))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.62))
                
                Spacer()
                
                Text("\(achievement.progressCurrent)/\(achievement.progressTarget)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                    
                    Capsule()
                        .fill(rarityColor)
                        .frame(width: proxy.size.width * achievement.progress)
                }
            }
            .frame(height: 10)
        }
    }
    
    private var statusView: some View {
        HStack(spacing: 8) {
            Image(systemName: achievement.isUnlocked ? "checkmark.seal.fill" : "lock.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(achievement.isUnlocked ? .green : .white.opacity(0.48))
            
            Text(achievement.isUnlocked ? String(localized: "perks.achievement.status_unlocked", bundle: .module) : String(localized: "perks.achievement.status_locked", bundle: .module))
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
    
    private var cardBackground: some View {
        LinearGradient(
            colors: backgroundColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.52),
                        rarityColor.opacity(0.35),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
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
                Color(red: 34 / 255, green: 36 / 255, blue: 48 / 255),
                base
            ]
        }
        
        switch achievement.rarity {
        case .common:
            return [
                Color.green.opacity(1.0),
                base
            ]
        case .rare:
            return [
                Color.blue.opacity(1.0),
                base
            ]
        case .epic:
            return [
                Color.orange.opacity(1.0),
                base
            ]
        case .legendary:
            return [
                Color.yellow.opacity(1.0),
                base
            ]
        }
    }
}

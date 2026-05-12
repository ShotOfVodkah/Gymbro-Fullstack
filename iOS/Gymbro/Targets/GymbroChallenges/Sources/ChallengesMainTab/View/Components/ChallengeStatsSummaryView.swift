import SwiftUI
import GymbroTypes

struct ChallengeStatsSummaryView: View {
    
    let activeCount: String
    let completedCount: String
    let teamsCount: String
    let availableCount: String
    
    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ],
            spacing: 10
        ) {
            statCard(title: String(localized: "challenges.stats.active", bundle: .module), value: activeCount, icon: "bolt.fill")
            statCard(title: String(localized: "challenges.stats.completed", bundle: .module), value: completedCount, icon: "checkmark.seal.fill")
            statCard(title: String(localized: "challenges.stats.teams", bundle: .module), value: teamsCount, icon: "person.3.fill")
            statCard(title: String(localized: "challenges.stats.available", bundle: .module), value: availableCount, icon: "flag.checkered")
        }
    }
    
    private func statCard(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 42, height: 42)
                
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            }
            
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.appPurple.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(LinearGradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.2), Color.clear],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing
                                      ),
                        lineWidth: 1
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                .blendMode(.screen)
        )
    }
}

import SwiftUI
import GymbroTypes

struct TeamProgressView: View {
    
    let details: ChallengeDetailsModel
    
    private var clampedProgress: Double {
        min(max(details.progressPercent, 0), 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle(
                String(localized: "challenges.details.team_progress.title", bundle: .module),
                String(localized: "challenges.details.team_progress.subtitle", bundle: .module)
            )
            
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .lastTextBaseline) {
                    Text("\(details.currentValue)")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(details.accentColor)
                    
                    Text("/ \(details.targetValue) \(details.unit.rawValue)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white.opacity(0.58))
                    
                    Spacer()
                    
                    Text("\(Int(clampedProgress * 100))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white.opacity(0.82))
                }
                
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.10))
                        
                        Capsule()
                            .fill(details.accentColor)
                            .frame(width: proxy.size.width * clampedProgress)
                            .shadow(color: details.accentColor.opacity(0.45), radius: 8)
                    }
                }
                .frame(height: 12)
                
                HStack {
                    progressPill(title: String(localized: "challenges.details.team_progress.current", bundle: .module), value: "\(details.currentValue)", icon: "bolt.fill")
                    progressPill(title: String(localized: "challenges.details.team_progress.target", bundle: .module), value: "\(details.targetValue)", icon: "target")
                }
            }
            .padding(18)
            .background(baseCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(.white.opacity(0.07), lineWidth: 1)
            )
        }
    }
    
    private func progressPill(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(details.accentColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.48))
                
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.07))
        )
    }
}

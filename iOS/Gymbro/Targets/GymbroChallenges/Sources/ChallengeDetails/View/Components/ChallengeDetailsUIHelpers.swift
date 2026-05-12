import SwiftUI
import GymbroTypes

extension ChallengeDetailsModel {
    
    var accentColor: Color {
        participationStatus.accentColor
    }
    
    var dateRangeText: String {
        let a = startDate.formatted(date: .abbreviated, time: .omitted)
        let b = endDate.formatted(date: .abbreviated, time: .omitted)
        return String(
            format: String(localized: "challenges.details.date_range", bundle: .module),
            locale: .current,
            a,
            b
        )
    }
}

@ViewBuilder
func sectionTitle(_ title: String, _ subtitle: String? = nil) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(title)
            .font(.system(size: 21, weight: .bold))
            .foregroundStyle(.white)
        
        if let subtitle {
            Text(subtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.52))
        }
    }
}

var baseCardBackground: some View {
    LinearGradient(
        colors: [
            Color(red: 18 / 255, green: 24 / 255, blue: 42 / 255).opacity(0.76),
            Color(red: 19 / 255, green: 30 / 255, blue: 56 / 255).opacity(0.62)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

import SwiftUI

struct StatisticsSummaryCard: View {
    
    init(
        title: String,
        value: Int,
        suffix: String = "",
        subtitle: String? = nil,
        iconSystemName: String
    ) {
        self.title = title
        self.value = value
        self.suffix = suffix
        self.subtitle = subtitle
        self.iconSystemName = iconSystemName
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: iconSystemName)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                }
                
                StatisticsAnimatedCounterText(
                    value: value,
                    suffix: suffix,
                    font: .title2.weight(.bold)
                )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.88))
                
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(2)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPurple.opacity(0.95),
                            Color.purple.opacity(0.72)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.55),
                            Color.white.opacity(0.08),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.appPurple.opacity(0.22), radius: 20, x: 0, y: 12)
    }
    
    private let title: String
    private let value: Int
    private let suffix: String
    private let subtitle: String?
    private let iconSystemName: String
}

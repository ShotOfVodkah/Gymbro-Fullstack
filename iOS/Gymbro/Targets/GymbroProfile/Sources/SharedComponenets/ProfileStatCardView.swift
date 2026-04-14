import SwiftUI

struct ProfileStatCardView: View {
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        iconSystemName: String? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.iconSystemName = iconSystemName
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let iconSystemName {
                    Image(systemName: iconSystemName)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.72))
                }
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
            }
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
            
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appPurple.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(LinearGradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.2), Color.clear],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing
                                      ),
                        lineWidth: 1
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                .blendMode(.screen)
        )
    }
    
    private let title: String
    private let value: String
    private let subtitle: String?
    private let iconSystemName: String?
}

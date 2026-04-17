import SwiftUI

struct ChatTypeSelectionStep: View {
    
    let onDirectTap: () -> Void
    let onGroupTap: () -> Void
    
    var body: some View {
        VStack(spacing: 18) {
            Text(String(localized: "feeds.chat.create.title", bundle: .module))
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
            
            Text(String(localized: "feeds.chat.create.subtitle", bundle: .module))
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                typeCard(
                    title: String(localized: "feeds.chat.direct.title", bundle: .module),
                    subtitle: String(localized: "feeds.chat.direct.subtitle", bundle: .module),
                    icon: "person.fill",
                    action: onDirectTap
                )
                
                typeCard(
                    title: String(localized: "feeds.chat.group.title", bundle: .module),
                    subtitle: String(localized: "feeds.chat.group.subtitle", bundle: .module),
                    icon: "person.3.fill",
                    action: onGroupTap
                )
            }
        }
    }
    
    private func typeCard(
        title: String,
        subtitle: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Circle()
                    .fill(Color.appPurple.opacity(0.8))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .overlay(
                        Circle()
                            .stroke(LinearGradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.2), Color.clear],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing
                                                  ),
                                    lineWidth: 1
                            )
                    )
                    .overlay(
                        Circle()
                            .fill(LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .blendMode(.screen)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
    }
}

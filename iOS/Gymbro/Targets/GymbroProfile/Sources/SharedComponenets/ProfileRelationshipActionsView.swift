import SwiftUI

struct ProfileRelationshipActionsView: View {
    
    init(
        followTitle: String,
        onFollowTap: @escaping () -> Void,
        onWriteTap: @escaping () -> Void,
        onPostsTap: @escaping () -> Void
    ) {
        self.followTitle = followTitle
        self.onFollowTap = onFollowTap
        self.onWriteTap = onWriteTap
        self.onPostsTap = onPostsTap
    }
    
    var body: some View {
        HStack(spacing: 12) {
            primaryButton(title: followTitle, systemName: "person.badge.plus", action: onFollowTap)
            
            secondaryButton(title: String(localized: "profile.relationship.write", bundle: .module), systemName: "paperplane", action: onWriteTap)
            
            secondaryButton(title: String(localized: "profile.relationship.posts", bundle: .module), systemName: "square.grid.2x2", action: onPostsTap)
        }
    }
    
    private func primaryButton(
        title: String,
        systemName: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemName)
                    .font(.subheadline.weight(.semibold))
                
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appPurple.opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(LinearGradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.2), Color.clear],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing
                                          ),
                            lineWidth: 1
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .blendMode(.screen)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func secondaryButton(
        title: String,
        systemName: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemName)
                    .font(.subheadline.weight(.semibold))
                
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private let followTitle: String
    private let onFollowTap: () -> Void
    private let onWriteTap: () -> Void
    private let onPostsTap: () -> Void
    private var cardBackground: some View {
        LinearGradient(
            colors: [Color.cardOne, Color.cardTwo],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.7)
    }
}

import SwiftUI

struct PostHeaderView: View {
    
    let avatar: String
    let authorName: String
    let postedAt: String
    let authorAccessibilityIdentifier: String?
    let onAuthorTap: () -> Void
    
    init(
        avatar: String,
        authorName: String,
        postedAt: String,
        authorAccessibilityIdentifier: String? = nil,
        onAuthorTap: @escaping () -> Void
    ) {
        self.avatar = avatar
        self.authorName = authorName
        self.postedAt = postedAt
        self.authorAccessibilityIdentifier = authorAccessibilityIdentifier
        self.onAuthorTap = onAuthorTap
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.appPurple, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: avatar)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Button(action: onAuthorTap) {
                    Text(authorName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .modifier(PostHeaderAccessibilityIdentifier(identifier: authorAccessibilityIdentifier))

                Text(postedAt)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.gray)
            }

            Spacer()
        }
    }
}

private struct PostHeaderAccessibilityIdentifier: ViewModifier {
    let identifier: String?

    func body(content: Content) -> some View {
        if let identifier {
            content.accessibilityIdentifier(identifier)
        } else {
            content
        }
    }
}

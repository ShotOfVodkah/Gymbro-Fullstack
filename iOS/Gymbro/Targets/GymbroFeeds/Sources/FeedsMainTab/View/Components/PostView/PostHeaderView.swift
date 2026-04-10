import SwiftUI

struct PostHeaderView: View {
    
    let avatar: String
    let authorName: String
    let postedAt: String
    let onAuthorTap: () -> Void
    
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

                Text(postedAt)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.gray)
            }

            Spacer()
        }
    }
}

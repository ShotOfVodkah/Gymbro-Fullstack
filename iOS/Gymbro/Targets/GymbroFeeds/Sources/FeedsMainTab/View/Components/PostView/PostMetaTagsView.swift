import SwiftUI

struct PostMetaTagsView: View {
    
    let category: String
    let duration: String
    let timeAgo: String
    
    var body: some View {
        HStack(spacing: 10) {
            metaCapsule(title: category, systemImage: nil, isAccent: true)
            metaCapsule(title: duration, systemImage: "timer", isAccent: false)
            metaCapsule(title: timeAgo, systemImage: "clock", isAccent: false)
        }
    }

    private func metaCapsule(title: String, systemImage: String?, isAccent: Bool) -> some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .bold))
            }

            Text(title)
                .font(.system(size: 15, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(isAccent ? Color.purple.opacity(0.4) : Color.white.opacity(0.07))
        )
    }
}

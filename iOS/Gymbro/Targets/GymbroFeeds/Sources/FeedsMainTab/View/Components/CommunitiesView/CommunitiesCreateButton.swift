import SwiftUI

struct CreateCommunityButtonView: View {
    
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appPurple.opacity(0.8), Color.pink.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 82, height: 82)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.white)
                    )

                Text("Create")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .frame(width: 84)
            }
        }
        .buttonStyle(.plain)
    }
}

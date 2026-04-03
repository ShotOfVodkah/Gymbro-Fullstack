import SwiftUI

struct CreateFeedActionButton: View {
    
    let title: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: "plus.bubble")
                    .font(.system(size: 18, weight: .semibold))

                Text(title)
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color.purple, Color.pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color.purple.opacity(0.35), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.black.ignoresSafeArea()
        CreateFeedActionButton(title: "Создать пост", onTap: {})
            .padding()
    }
}

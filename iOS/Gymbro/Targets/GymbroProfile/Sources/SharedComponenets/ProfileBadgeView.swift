import SwiftUI

struct ProfileBadgeView: View {
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.purple.opacity(0.4))
            )
    }
    
    private let title: String
}

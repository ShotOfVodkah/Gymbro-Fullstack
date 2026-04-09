import SwiftUI

struct ChatCreationHeaderView: View {
    
    let title: String
    let onBackTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBackTap) {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(.plain)
            
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
            
            Spacer()
        }
    }
}

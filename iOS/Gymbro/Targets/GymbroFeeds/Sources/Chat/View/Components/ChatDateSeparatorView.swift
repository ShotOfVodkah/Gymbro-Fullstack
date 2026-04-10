import SwiftUI

struct ChatDateSeparatorView: View {
    
    let title: String
    
    var body: some View {
        HStack {
            Spacer()
            
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.65))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

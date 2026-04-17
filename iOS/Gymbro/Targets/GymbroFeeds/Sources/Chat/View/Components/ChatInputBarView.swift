import SwiftUI

struct ChatInputBarView: View {
    
    @Binding var text: String
    let onSendTap: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(String(localized: "feeds.chat.placeholder", bundle: .module))
                        .foregroundStyle(.white.opacity(0.45))
                        .padding(.horizontal, 14)
                }
                
                TextField("", text: $text, axis: .vertical)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                    .lineLimit(1...4)
            }
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            
            Button(action: onSendTap) {
                Circle()
                    .fill(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.white.opacity(0.12) : Color.appPurple)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(.plain)
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}

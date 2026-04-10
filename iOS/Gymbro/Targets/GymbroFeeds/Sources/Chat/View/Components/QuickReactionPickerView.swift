import SwiftUI

struct QuickReactionPickerView: View {
    
    let emojis: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(emojis, id: \.self) { emoji in
                Button {
                    onSelect(emoji)
                } label: {
                    Text(emoji)
                        .font(.system(size: 20))
                        .padding(8)
                        .background(Color.black.opacity(0.8))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        QuickReactionPickerView(
            emojis: ["🔥", "💪", "✅", "👏"],
            onSelect: { _ in }
        )

    }
}

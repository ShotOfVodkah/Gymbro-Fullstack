import SwiftUI

struct EditProfileBioEditor: View {
    
    init(
        text: Binding<String>,
        limit: Int
    ) {
        self._text = text
        self.limit = limit
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .frame(height: 120)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )
                .foregroundStyle(.white)
            
            Text("\(text.count)/\(limit)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    @Binding private var text: String
    private let limit: Int
}

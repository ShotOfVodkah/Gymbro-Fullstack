import SwiftUI

public struct AppTextField: View {
    
    let title: String?
    let placeholder: String
    var text: Binding<String>
    
    public init(
        title: String? = nil,
        placeholder: String,
        text: Binding<String>
    ) {
        self.title = title
        self.placeholder = placeholder
        self.text = text
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            if let title {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            TextField(placeholder, text: text)
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color.appDarkGray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
        }
    }
}

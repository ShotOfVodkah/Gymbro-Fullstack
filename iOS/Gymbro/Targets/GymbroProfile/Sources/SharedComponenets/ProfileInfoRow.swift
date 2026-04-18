import SwiftUI

struct ProfileInfoRow: View {
    
    init(
        iconSystemName: String,
        text: String,
        textColor: Color = .white.opacity(0.72)
    ) {
        self.iconSystemName = iconSystemName
        self.text = text
        self.textColor = textColor
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: iconSystemName)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .frame(width: 16)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(textColor)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 0)
        }
    }
    
    private let iconSystemName: String
    private let text: String
    private let textColor: Color
}

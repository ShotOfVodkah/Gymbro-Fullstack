import SwiftUI

struct EditProfileTextField: View {
    
    init(
        title: String,
        text: Binding<String>,
        autocapitalization: TextInputAutocapitalization = .never,
        disableAutocorrection: Bool = true,
        accessibilityIdentifier: String
    ) {
        self.title = title
        self._text = text
        self.autocapitalization = autocapitalization
        self.disableAutocorrection = disableAutocorrection
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            
            TextField("", text: $text)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(disableAutocorrection)
                .accessibilityIdentifier(accessibilityIdentifier)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )
                .foregroundStyle(.white)
        }
    }
    
    private let title: String
    @Binding private var text: String
    private let autocapitalization: TextInputAutocapitalization
    private let disableAutocorrection: Bool
    private let accessibilityIdentifier: String
}

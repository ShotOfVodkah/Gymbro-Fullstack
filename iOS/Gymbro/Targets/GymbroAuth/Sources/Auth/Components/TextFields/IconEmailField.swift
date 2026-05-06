import SwiftUI

struct IconEmailField: View {
    let title: String
    let systemImage: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 23)

                TextField("", text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .foregroundStyle(.white)
                    .accessibilityIdentifier("auth.email.textfield")
                    .placeholder(when: text.isEmpty) {
                        Text(String(localized: "auth.placeholder.email", bundle: .module))
                            .foregroundColor(.white.opacity(0.6))
                            .bold()
                    }
            }
            .padding(.horizontal, 14)
            .frame(height: 54)
            .background(Color.black.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
            )
        }
    }
}

import SwiftUI


struct IconSecureField: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    @Binding var isHidden: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 23)

                Group {
                    if isHidden {
                        SecureField("", text: $text)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .placeholder(when: text.isEmpty) {
                                Text("Enter your password")
                                    .foregroundColor(.white.opacity(0.6))
                                    .bold()
                            }
                    } else {
                        TextField("", text: $text)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .placeholder(when: text.isEmpty) {
                                Text("Enter your password")
                                    .foregroundColor(.white.opacity(0.6))
                                    .bold()
                            }
                    }
                }
                .foregroundStyle(.white)

                Button {
                    isHidden.toggle()
                } label: {
                    Image(systemName: isHidden ? "eye.slash" : "eye")
                        .foregroundStyle(.white.opacity(0.6))
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

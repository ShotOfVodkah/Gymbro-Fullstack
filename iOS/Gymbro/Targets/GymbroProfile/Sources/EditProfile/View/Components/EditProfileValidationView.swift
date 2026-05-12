import SwiftUI

struct EditProfileValidationView: View {
    
    init(messages: [String]) {
        self.messages = messages
    }
    
    var body: some View {
        ProfileSectionContainer(title: String(localized: "edit_profile.validation_title", bundle: .module)) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(messages, id: \.self) { message in
                    Text("• \(message)")
                        .font(.subheadline)
                        .foregroundStyle(.red.opacity(0.9))
                }
            }
        }
    }
    
    private let messages: [String]
}

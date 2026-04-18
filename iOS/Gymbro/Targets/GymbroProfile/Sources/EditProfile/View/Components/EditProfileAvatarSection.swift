import SwiftUI

struct EditProfileAvatarSection: View {
    
    init(
        avatarSystemName: String,
        subtitle: String = "Avatar selection will be expanded later"
    ) {
        self.avatarSystemName = avatarSystemName
        self.subtitle = subtitle
    }
    
    var body: some View {
        ProfileSectionContainer {
            VStack(spacing: 16) {
                ProfileAvatarView(
                    systemName: avatarSystemName,
                    size: 96
                )
                
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private let avatarSystemName: String
    private let subtitle: String
}

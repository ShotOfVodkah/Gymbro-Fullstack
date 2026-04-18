import SwiftUI
import GymbroTypes

struct ProfileHeaderView: View {
    
    init(model: ProfileHeaderModel) {
        self.model = model
    }
    
    var body: some View {
        ProfileSectionContainer {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 16) {
                    ProfileAvatarView(
                        systemName: model.avatarSystemName,
                        size: 84
                    )
                    
                    VStack(alignment: .leading, spacing: 7) {
                        Text(model.fullName)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        HStack(spacing: 16) {
                            Text(model.username)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.65))
                            
                            if let badge = model.badge {
                                ProfileBadgeView(title: badge)
                            }
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
                
                if !model.status.isEmpty {
                    ProfileInfoRow(
                        iconSystemName: "quote.bubble",
                        text: model.status,
                        textColor: .white
                    )
                }
                
                if !model.subtitle.isEmpty {
                    ProfileInfoRow(
                        iconSystemName: "figure.strengthtraining.traditional",
                        text: model.subtitle
                    )
                }
            }
        }
    }
    
    private let model: ProfileHeaderModel
}

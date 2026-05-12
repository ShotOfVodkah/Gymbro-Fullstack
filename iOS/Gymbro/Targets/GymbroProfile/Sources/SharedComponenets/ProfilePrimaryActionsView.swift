import SwiftUI
import GymbroTypes

struct ProfilePrimaryActionsView: View {
    
    init(
        actions: [ProfileActionModel],
        onTap: @escaping (ProfileActionKind) -> Void
    ) {
        self.actions = actions
        self.onTap = onTap
    }
    
    var body: some View {
        ProfileSectionContainer(title: String(localized: "profile.actions.section", bundle: .module)) {
            VStack(spacing: 10) {
                ForEach(actions) { action in
                    ProfileActionButton(model: action) {
                        onTap(action.kind)
                    }
                }
            }
        }
    }
    
    private let actions: [ProfileActionModel]
    private let onTap: (ProfileActionKind) -> Void
}

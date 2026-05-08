import SwiftUI
import GymbroCommonUI

struct FeedsEmptyStateView: View {
    
    let systemImage: String
    let title: String
    let subtitle: String?
    let primaryActionTitle: String?
    let onPrimaryActionTap: (() -> Void)?
    
    init(
        systemImage: String,
        title: String,
        subtitle: String? = nil,
        primaryActionTitle: String? = nil,
        onPrimaryActionTap: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.subtitle = subtitle
        self.primaryActionTitle = primaryActionTitle
        self.onPrimaryActionTap = onPrimaryActionTap
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.white.opacity(0.75))
                .padding(.bottom, 2)
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.62))
                    .multilineTextAlignment(.center)
            }
            
            if let primaryActionTitle,
               let onPrimaryActionTap {
                AppButton(primaryActionTitle, size: .xl) {
                    onPrimaryActionTap()
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}


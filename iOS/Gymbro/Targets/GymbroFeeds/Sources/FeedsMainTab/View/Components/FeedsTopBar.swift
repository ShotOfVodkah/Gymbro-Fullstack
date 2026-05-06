import SwiftUI
import GymbroCommonUI

struct FeedsTopBar: View {
    
    let onPeopleTap: () -> Void
    let onCalendarTap: () -> Void
    
    var body: some View {
        HStack {
            AppButton(systemImage: "person.2.badge.plus", size: .l, action: onPeopleTap)
                .accessibilityIdentifier("feeds.topbar.friends")

            Spacer()
            
            Text(String(localized: "feeds.topbar.title", bundle: .module))
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            AppButton(systemImage: "calendar", size: .l, action: onCalendarTap)
                .accessibilityIdentifier("feeds.topbar.calendar")
        }
        .padding(.horizontal, 20)
    }
}

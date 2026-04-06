import SwiftUI
import GymbroCommonUI

struct FeedsTopBar: View {
    
    let onPeopleTap: () -> Void
    let onCalendarTap: () -> Void
    
    var body: some View {
        HStack {
            AppButton(systemImage: "person.2.badge.plus", size: .l, action: onPeopleTap)

            Spacer()
            
            Text("GymBro")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            AppButton(systemImage: "calendar", size: .l, action: onCalendarTap)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

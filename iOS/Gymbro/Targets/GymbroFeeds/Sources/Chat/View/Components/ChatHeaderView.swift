import SwiftUI
import GymbroCommonUI

struct ChatHeaderView: View {
    
    let title: String
    let isGroup: Bool
    let onBackTap: () -> Void
    let onTitleTap: () -> Void
    let onCalendarTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBackTap) {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(.plain)
            
            Button(action: onTitleTap) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appPurple, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)
                        .overlay(
                            Image(systemName: isGroup ? "person.3.fill" : "person.fill")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        
                        Text(isGroup ? "Group chat" : "Direct chat")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.65))
                    }
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            AppButton(systemImage: "calendar", size: .m, action: onCalendarTap)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

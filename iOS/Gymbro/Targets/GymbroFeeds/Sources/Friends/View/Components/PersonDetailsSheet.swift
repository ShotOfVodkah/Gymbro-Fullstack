import SwiftUI
import GymbroCommonUI

struct PersonDetailsSheet: View {
    
    let person: PersonItem
    let onFollowTap: () -> Void
    let onViewProfileTap: () -> Void
    let onViewMessageTap: () -> Void
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 18/255, green: 20/255, blue: 28/255),
                        Color(red: 28/255, green: 32/255, blue: 42/255),
                        Color(red: 20/255, green: 24/255, blue: 34/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        Spacer(minLength: 0)
                        
                        content
                        
                        Spacer(minLength: 0)
                    }
                    .frame(
                        maxWidth: .infinity,
                        minHeight: proxy.size.height - 24
                    )
                    .padding(.horizontal, 18)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    private var content: some View {
        VStack(spacing: 20) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.appPurple, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 84, height: 84)
                .overlay(
                    Image(systemName: person.avatarSystemName)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                )
            
            VStack(spacing: 6) {
                Text(person.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(person.status)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                
                Text("\(person.workoutsThisMonth) workouts this month")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            VStack(spacing: 10) {
                AppButton(
                    person.isFollowing ? "Unfollow" : "Follow",
                    size: .l,
                    action: onFollowTap,
                    wrapContent: false
                )
                
                AppButton(
                    "View profile & workouts",
                    size: .l,
                    action: onViewProfileTap,
                    wrapContent: false
                )
                
                AppButton(
                    "Message",
                    size: .l,
                    action: onViewMessageTap,
                    wrapContent: false
                )
            }
            .frame(maxWidth: 220)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 26)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

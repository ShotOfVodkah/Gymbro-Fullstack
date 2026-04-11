import SwiftUI
import GymbroTypes

struct PersonRowView: View {
    
    let person: PersonItem
    let onTap: () -> Void
    let onFollowTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 14) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appPurple, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image(systemName: person.avatarSystemName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(person.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        if let badge = person.badge {
                            Text(badge)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white.opacity(0.85))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.08))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(person.status)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Text(person.username)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.gray)
                }
                
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            
            followButton
        }
        .padding(15)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
    
    private var followButton: some View {
        Button(action: onFollowTap) {
            Text(person.isFollowing ? "Following" : "Follow")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    person.isFollowing
                    ? Color.white.opacity(0.10)
                    : Color.purple.opacity(0.7)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

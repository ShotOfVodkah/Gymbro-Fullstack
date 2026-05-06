import SwiftUI
import GymbroTypes

struct ChallengeCardView: View {
    
    let challenge: ChallengeCardModel
    let onTap: () -> Void
    let onJoinTap: (() -> Void)?
    
    private var accentColor: Color {
        challenge.status.accentColor
    }
    
    private var accentGradient: LinearGradient {
        switch challenge.status {
        case .notJoined:
            return LinearGradient(
                colors: [.blue.opacity(0.95), .cyan.opacity(0.72)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .inProgress:
            return LinearGradient(
                colors: [.orange.opacity(0.95), .yellow.opacity(0.82)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .completed:
            return LinearGradient(
                colors: [.green.opacity(0.95), .mint.opacity(0.78)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .failed:
            return LinearGradient(
                colors: [.red.opacity(0.95), .orange.opacity(0.72)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private var cardBackgroundColors: [Color] {
        switch challenge.status {
        case .notJoined:
            return [
                Color(red: 18 / 255, green: 28 / 255, blue: 46 / 255),
                Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255)
            ]
        case .inProgress:
            return [
                Color(red: 44 / 255, green: 28 / 255, blue: 18 / 255),
                Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255)
            ]
        case .completed:
            return [
                Color(red: 18 / 255, green: 44 / 255, blue: 34 / 255),
                Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255)
            ]
        case .failed:
            return [
                Color(red: 44 / 255, green: 18 / 255, blue: 32 / 255),
                Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255)
            ]
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 18) {
                headerView
                progressView
                metaView
                footerView
            }
            .padding(20)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("challenges.card.\(challenge.id)")
    }
    
    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(challenge.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text(challenge.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.64))
                    .lineLimit(2)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.18))
                    .frame(width: 52, height: 52)
                
                Image(systemName: challenge.iconName)
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(accentColor)
            }
        }
    }
    
    private var progressView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .lastTextBaseline) {
                Text(challenge.progressText)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(accentColor)
                
                Spacer()
                
                Text("\(Int(challenge.progressPercent * 100))%")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white.opacity(0.82))
            }
            
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.10))
                    
                    Capsule()
                        .fill(accentGradient)
                        .frame(width: proxy.size.width * min(max(challenge.progressPercent, 0), 1))
                        .shadow(color: accentColor.opacity(0.45), radius: 8, x: 0, y: 0)
                }
            }
            .frame(height: 12)
            
            Text("Team challenge progress")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.48))
        }
    }
    
    private var metaView: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let targetText = challenge.targetText {
                HStack(spacing: 7) {
                    Image(systemName: "scope")
                        .font(.system(size: 12, weight: .semibold))
                    
                    Text(targetText)
                        .font(.system(size: 12, weight: .bold))
                        .lineLimit(1)
                    
                    Spacer(minLength: 0)
                }
                .foregroundStyle(challenge.status.accentColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(challenge.status.accentColor.opacity(0.13))
                )
                .overlay(
                    Capsule()
                        .stroke(challenge.status.accentColor.opacity(0.18), lineWidth: 1)
                )
            }
            
            HStack(spacing: 10) {
                if challenge.isJoined {
                    metaPill(
                        title: "Team",
                        value: challenge.teamName ?? "Team",
                        iconName: "person.3.fill"
                    )
                } else {
                    joinPill
                }
                
                metaPill(
                    title: "Members",
                    value: challenge.membersCount.map { "\($0)" } ?? "—",
                    iconName: "person.2.fill"
                )
            }
        }
    }
    
    private var joinPill: some View {
        Button {
            onJoinTap?()
        } label: {
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 5) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                    
                    Text("Entry")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(.white.opacity(0.56))
                
                Text("Choose team")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.blue.opacity(0.13))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.blue.opacity(0.22), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("challenges.card.\(challenge.id).join")
    }
    
    private var footerView: some View {
        HStack(spacing: 8) {
            ChallengeDifficultyBadgeView(difficulty: challenge.difficulty)
            ChallengeStatusBadgeView(status: challenge.status)
            
            Spacer()
            
            Text(challenge.dateText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.52))
        }
    }
    
    private func metaPill(
        title: String,
        value: String,
        iconName: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 5) {
                Image(systemName: iconName)
                    .font(.system(size: 12, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(0.56))
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.04), lineWidth: 1)
        )
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(
                LinearGradient(
                    colors: cardBackgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.7)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.22),
                                accentColor.opacity(0.95),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

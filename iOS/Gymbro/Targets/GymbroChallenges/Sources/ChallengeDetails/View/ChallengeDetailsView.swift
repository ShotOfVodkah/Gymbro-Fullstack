import SwiftUI
import GymbroCommonUI
import GymbroTypes

struct ChallengeDetailsView: View {
    
    init(viewModel: ChallengeDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            Group {
                switch viewModel.screenState {
                case .loading:
                    ChallengeDetailsViewStub()
                    
                case .loaded:
                    if let details = viewModel.details {
                        contentView(details)
                    }
                    
                case .error:
                    errorView
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func contentView(_ details: ChallengeDetailsModel) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                topBar
                
                ChallengeHeaderView(details: details)
                
                TeamProgressView(details: details)
                
                ChallengeRulesView(rules: details.rules)
                
                ChallengeTeamSectionView(
                    details: details,
                    onActionTap: {
                        viewModel.teamActionTapped()
                    },
                    onJoinAnotherTeamTap: {
                        viewModel.joinAnotherTeamTapped()
                    }
                )
                
                ChallengeParticipantsView(participants: details.participants)
                
                ChallengeActivityTimelineView(activity: viewModel.activity)
                
                ChallengeLeaderboardPreviewView(
                    teams: Array(viewModel.leaderboard.prefix(3)),
                    onTap: viewModel.leaderboardTapped
                )
                
                ChallengeRewardsView(rewards: details.rewards)
                
                if details.participationStatus == .inProgress {
                    leaveChallengeButton
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 16)
            .padding(.bottom, 70)
        }
        .refreshable {
            viewModel.reload()
        }
    }
    
    private var topBar: some View {
        HStack {
            Button {
                viewModel.backButtonTapped()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.08))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Challenge")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
            
            Spacer()
            
            Color.clear
                .frame(width: 42, height: 42)
        }
    }
    
    private var leaveChallengeButton: some View {
        Button {
            viewModel.leaveChallengeTapped()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15, weight: .semibold))
                
                Text("Leave Challenge")
                    .font(.system(size: 15, weight: .bold))
                
                Spacer()
            }
            .foregroundStyle(.red.opacity(0.95))
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.red.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.red.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Text(GymbroCommonStrings.genericError)
                .font(.title3)
                .foregroundStyle(.white)
            
            AppButton(GymbroCommonStrings.refresh, size: .xl) {
                viewModel.reload()
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 12 / 255, green: 18 / 255, blue: 36 / 255),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    @ObservedObject private var viewModel: ChallengeDetailsViewModel
}

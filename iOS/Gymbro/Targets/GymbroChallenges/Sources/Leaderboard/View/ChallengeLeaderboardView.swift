import SwiftUI
import GymbroCommonUI
import GymbroTypes

struct ChallengeLeaderboardView: View {
    
    init(viewModel: ChallengeLeaderboardViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            Group {
                switch viewModel.screenState {
                case .loading:
                    ChallengeLeaderboardViewStub()
                    
                case .loaded:
                    contentView
                    
                case .empty:
                    emptyView
                    
                case .error:
                    errorView
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                topBar
                headerView
                
                if !viewModel.topThreeTeams.isEmpty {
                    LeaderboardPodiumView(
                        teams: viewModel.topThreeTeams,
                        onTap: viewModel.teamTapped
                    )
                }
                
                VStack(alignment: .leading, spacing: 13) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("All Teams")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Tap a team to open its group chat")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.52))
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(viewModel.teams) { team in
                            LeaderboardTeamRowView(team: team) {
                                viewModel.teamTapped(team)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .refreshable {
            viewModel.reload()
        }
        .overlay(alignment: .topLeading) {
            UITestMarker(id: "challenges.leaderboard.loaded")
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
            .accessibilityIdentifier("challenges.leaderboard.back")
            
            Spacer()
            
            Text("Leaderboard")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
            
            Spacer()
            
            Color.clear
                .frame(width: 42, height: 42)
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.18))
                    .frame(width: 58, height: 58)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.yellow)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Team standings")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Compare team progress, current values, and ranking inside this challenge.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 15) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.white.opacity(0.65))
            
            Text("No teams yet")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
            
            Text("When teams join this challenge, their progress will appear here.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.58))
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.reload()
            } label: {
                Text("Refresh")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 13)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.1))
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(.horizontal, 36)
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
    
    @ObservedObject private var viewModel: ChallengeLeaderboardViewModel
}

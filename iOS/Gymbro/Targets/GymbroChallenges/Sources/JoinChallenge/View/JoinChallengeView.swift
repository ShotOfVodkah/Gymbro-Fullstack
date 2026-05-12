import SwiftUI
import GymbroCommonUI
import GymbroTypes

struct JoinChallengeView: View {
    
    init(viewModel: JoinChallengeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            Group {
                switch viewModel.screenState {
                case .loading:
                    JoinChallengeViewStub()
                    
                case .loaded:
                    contentView
                    
                case .success:
                    successView
                    
                case .error:
                    errorView
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $viewModel.isConfirmationPresented) {
            if let team = viewModel.selectedTeam {
                JoinChallengeConfirmationView(
                    team: team,
                    onCancel: {
                        viewModel.isConfirmationPresented = false
                    },
                    onConfirm: {
                        viewModel.confirmJoinTapped()
                    }
                )
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                topBar
                
                headerView
                
                teamsSummaryView
                
                VStack(alignment: .leading, spacing: 13) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "challenges.join.section_title", bundle: .module))
                            .font(.system(size: 23, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text(String(localized: "challenges.join.section_subtitle", bundle: .module))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.52))
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(viewModel.teams) { team in
                            AvailableTeamCardView(team: team) {
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
            UITestMarker(id: "challenges.join.loaded")
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
            .accessibilityIdentifier("challenges.join.back")
            
            Spacer()
            
            Text(String(localized: "challenges.join.nav_title", bundle: .module))
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
            
            Spacer()
            
            Color.clear
                .frame(width: 42, height: 42)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.18))
                    .frame(width: 58, height: 58)
                
                Image(systemName: "person.3.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.blue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "challenges.join.pick_squad_title", bundle: .module))
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(String(localized: "challenges.join.pick_squad_subtitle", bundle: .module))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.18),
                            Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255).opacity(0.78)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.22),
                            .blue.opacity(0.72),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    private var teamsSummaryView: some View {
        HStack(spacing: 10) {
            summaryPill(
                title: String(localized: "challenges.join.summary_available", bundle: .module),
                value: viewModel.availableTeamsCountText,
                iconName: "checkmark.circle.fill",
                color: .green
            )
            
            summaryPill(
                title: String(localized: "challenges.join.summary_group_chats", bundle: .module),
                value: "\(viewModel.teams.count)",
                iconName: "bubble.left.and.bubble.right.fill",
                color: .blue
            )
        }
    }
    
    private func summaryPill(
        title: String,
        value: String,
        iconName: String,
        color: Color
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(color.opacity(0.16))
                    .frame(width: 42, height: 42)
                
                Image(systemName: iconName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            }
            
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white.opacity(0.055))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.09), lineWidth: 1)
        )
    }
    
    private var successView: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.18))
                    .frame(width: 86, height: 86)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(.green)
            }
            
            Text(String(localized: "challenges.join.success_title", bundle: .module))
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
            
            Text(String(localized: "challenges.join.success_subtitle", bundle: .module))
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.62))
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.successDoneTapped()
            } label: {
                Text(String(localized: "challenges.join.back_to_challenge", bundle: .module))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.green.opacity(0.28))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.green.opacity(0.26), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
            .accessibilityIdentifier("challenges.join.success.done")
        }
        .padding(.horizontal, 32)
        .overlay(alignment: .topLeading) {
            UITestMarker(id: "challenges.join.success")
        }
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
    
    @ObservedObject private var viewModel: JoinChallengeViewModel
}

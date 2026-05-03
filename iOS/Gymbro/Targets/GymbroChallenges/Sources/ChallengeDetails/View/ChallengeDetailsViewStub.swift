import SwiftUI
import GymbroCommonUI

struct ChallengeDetailsViewStub: View {
    
    var body: some View {
        ZStack {
            backgroundView
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    topBar
                    headerSkeleton
                    progressSkeleton
                    rulesSkeleton
                    teamSkeleton
                    participantsSkeleton
                    activitySkeleton
                    leaderboardSkeleton
                    rewardsSkeleton
                }
                .padding(.horizontal, 15)
                .padding(.top, 16)
                .padding(.bottom, 70)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
        }
        .shimmer(active: true)
    }
    
    private var topBar: some View {
        HStack {
            Circle()
                .fill(SkeletonFill())
                .frame(width: 42, height: 42)
            
            Spacer()
            
            RoundedRectLine(width: 100, height: 22, cornerRadius: 8)
            
            Spacer()
            
            Circle()
                .fill(Color.clear)
                .frame(width: 42, height: 42)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var headerSkeleton: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 9) {
                    RoundedRectLine(width: 210, height: 32, cornerRadius: 10)
                    RoundedRectLine(width: 250, height: 14, cornerRadius: 7)
                    RoundedRectLine(width: 210, height: 14, cornerRadius: 7)
                }
                
                Spacer(minLength: 8)
                
                Circle()
                    .fill(SkeletonFill())
                    .frame(width: 58, height: 58)
            }
            
            HStack(spacing: 8) {
                pill(width: 92)
                pill(width: 82)
            }
            
            RoundedRectLine(width: 230, height: 14, cornerRadius: 7)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
    
    private var progressSkeleton: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionHeader(titleWidth: 150, subtitleWidth: 210)
            
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    RoundedRectLine(width: 140, height: 38, cornerRadius: 10)
                    
                    Spacer()
                    
                    RoundedRectLine(width: 46, height: 16, cornerRadius: 7)
                }
                
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(SkeletonFill())
                    .frame(height: 12)
                
                HStack(spacing: 10) {
                    statPill
                    statPill
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var rulesSkeleton: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionHeader(titleWidth: 70, subtitleWidth: 220)
            
            VStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(SkeletonFill())
                            .frame(width: 16, height: 16)
                        
                        RoundedRectLine(width: 230, height: 14, cornerRadius: 7)
                        
                        Spacer(minLength: 0)
                    }
                    .padding(13)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.white.opacity(0.06))
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var teamSkeleton: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionHeader(titleWidth: 70, subtitleWidth: 220)
            
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(SkeletonFill())
                    .frame(width: 54, height: 54)
                
                VStack(alignment: .leading, spacing: 7) {
                    RoundedRectLine(width: 140, height: 17, cornerRadius: 7)
                    RoundedRectLine(width: 160, height: 13, cornerRadius: 6)
                }
                
                Spacer(minLength: 8)
                
                pill(width: 78)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var participantsSkeleton: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionHeader(titleWidth: 200, subtitleWidth: 180)
            
            VStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { _ in
                    participantRow
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var participantRow: some View {
        HStack(spacing: 12) {
            RoundedRectLine(width: 28, height: 14, cornerRadius: 6)
            
            Circle()
                .fill(SkeletonFill())
                .frame(width: 42, height: 42)
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectLine(width: 120, height: 14, cornerRadius: 7)
                RoundedRectLine(width: 90, height: 12, cornerRadius: 6)
            }
            
            Spacer(minLength: 0)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.06))
        )
    }
    
    private var activitySkeleton: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionHeader(titleWidth: 90, subtitleWidth: 150)
            
            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(SkeletonFill())
                                .frame(width: 10, height: 10)
                            
                            Rectangle()
                                .fill(.white.opacity(0.08))
                                .frame(width: 2, height: 44)
                        }
                        .padding(.top, 5)
                        
                        VStack(alignment: .leading, spacing: 7) {
                            RoundedRectLine(width: 180, height: 14, cornerRadius: 7)
                            RoundedRectLine(width: 110, height: 12, cornerRadius: 6)
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var leaderboardSkeleton: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top) {
                sectionHeader(titleWidth: 130, subtitleWidth: 170)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                RoundedRectLine(width: 55, height: 13, cornerRadius: 6)
            }
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { _ in
                    participantRow
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var rewardsSkeleton: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionHeader(titleWidth: 90, subtitleWidth: 220)
            
            VStack(spacing: 10) {
                ForEach(0..<2, id: \.self) { _ in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(SkeletonFill())
                            .frame(width: 46, height: 46)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            RoundedRectLine(width: 130, height: 14, cornerRadius: 7)
                            RoundedRectLine(width: 200, height: 12, cornerRadius: 6)
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .padding(13)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.white.opacity(0.06))
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func sectionHeader(titleWidth: CGFloat, subtitleWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectLine(width: titleWidth, height: 21, cornerRadius: 8)
            RoundedRectLine(width: subtitleWidth, height: 13, cornerRadius: 7)
        }
    }
    
    private var statPill: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(SkeletonFill())
                .frame(width: 18, height: 18)
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectLine(width: 58, height: 11, cornerRadius: 5)
                RoundedRectLine(width: 36, height: 14, cornerRadius: 6)
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.07))
        )
    }
    
    private func pill(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 999, style: .continuous)
            .fill(SkeletonFill())
            .frame(width: width, height: 34)
    }
    
    private var cardBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 18 / 255, green: 24 / 255, blue: 42 / 255).opacity(0.75),
                Color(red: 19 / 255, green: 30 / 255, blue: 56 / 255).opacity(0.65)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
}

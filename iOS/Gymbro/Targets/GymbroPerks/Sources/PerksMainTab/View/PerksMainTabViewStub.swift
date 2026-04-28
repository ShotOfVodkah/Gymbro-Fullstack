import SwiftUI
import GymbroCommonUI

struct PerksViewStub: View {
    
    var body: some View {
        ZStack {
            backgroundView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    headerSkeleton
                    streakSkeleton
                    recentUnlocksSkeleton
                    achievementsSkeleton
                    leaderboardSkeleton
                }
                .padding(.horizontal, 15)
                .padding(.top, 18)
                .padding(.bottom, 120)
            }
        }
        .shimmer(active: true)
    }
    
    private var headerSkeleton: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectLine(width: 110, height: 34, cornerRadius: 10)
            RoundedRectLine(width: 290, height: 15, cornerRadius: 7)
            RoundedRectLine(width: 210, height: 15, cornerRadius: 7)
        }
    }
    
    private var streakSkeleton: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectLine(width: 135, height: 18, cornerRadius: 7)
                    RoundedRectLine(width: 230, height: 14, cornerRadius: 7)
                }
                
                Spacer()
                
                Circle()
                    .fill(SkeletonFill())
                    .frame(width: 52, height: 52)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .lastTextBaseline) {
                    RoundedRectLine(width: 78, height: 38, cornerRadius: 10)
                    RoundedRectLine(width: 48, height: 22, cornerRadius: 8)
                    Spacer()
                    RoundedRectLine(width: 52, height: 15, cornerRadius: 7)
                }
                
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(SkeletonFill())
                    .frame(height: 12)
                
                RoundedRectLine(width: 130, height: 12, cornerRadius: 6)
            }
            
            HStack(spacing: 10) {
                statSkeleton
                statSkeleton
                statSkeleton
            }
            
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(SkeletonFill())
                .frame(height: 66)
            
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(SkeletonFill())
                .frame(height: 48)
            
            RoundedRectLine(width: 240, height: 13, cornerRadius: 6)
        }
        .padding(20)
        .background(sectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(sectionBorder)
    }
    
    private var statSkeleton: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectLine(width: 54, height: 12, cornerRadius: 6)
            RoundedRectLine(width: 70, height: 15, cornerRadius: 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(SkeletonFill())
        )
    }
    
    private var recentUnlocksSkeleton: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeaderSkeleton(titleWidth: 140, subtitleWidth: 210)
            
            HStack(spacing: 10) {
                squareCardSkeleton
                squareCardSkeleton
                squareCardSkeleton
            }
        }
        .padding(20)
        .background(sectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(sectionBorder)
    }
    
    private var achievementsSkeleton: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeaderSkeleton(titleWidth: 130, subtitleWidth: 110)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<5, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 999, style: .continuous)
                            .fill(SkeletonFill())
                            .frame(width: 86, height: 36)
                    }
                }
            }
            
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    squareCardSkeleton
                    squareCardSkeleton
                    squareCardSkeleton
                }
                
                HStack(spacing: 10) {
                    squareCardSkeleton
                    squareCardSkeleton
                    squareCardSkeleton
                }
            }
        }
        .padding(20)
        .background(sectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(sectionBorder)
    }
    
    private var leaderboardSkeleton: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeaderSkeleton(titleWidth: 132, subtitleWidth: 245)
            
            HStack(spacing: 10) {
                filterPillSkeleton
                filterPillSkeleton
                filterPillSkeleton
            }
            
            HStack(spacing: 10) {
                filterPillSkeleton
                filterPillSkeleton
            }
            
            myRankSkeleton
            
            VStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { _ in
                    leaderboardRowSkeleton
                }
            }
        }
        .padding(20)
        .background(sectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(sectionBorder)
    }
    
    private var myRankSkeleton: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(SkeletonFill())
                .frame(width: 52, height: 52)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectLine(width: 92, height: 17, cornerRadius: 7)
                RoundedRectLine(width: 210, height: 13, cornerRadius: 6)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color.appPurple.opacity(0.16),
                    Color.purple.opacity(0.14)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    private var leaderboardRowSkeleton: some View {
        HStack(spacing: 12) {
            RoundedRectLine(width: 32, height: 14, cornerRadius: 6)
            
            Circle()
                .fill(SkeletonFill())
                .frame(width: 46, height: 46)
            
            VStack(alignment: .leading, spacing: 7) {
                RoundedRectLine(width: 92, height: 15, cornerRadius: 6)
                RoundedRectLine(width: 68, height: 12, cornerRadius: 6)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 7) {
                RoundedRectLine(width: 42, height: 16, cornerRadius: 6)
                RoundedRectLine(width: 58, height: 11, cornerRadius: 5)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(SkeletonFill())
        )
    }
    
    private var squareCardSkeleton: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(SkeletonFill())
                .frame(width: 42, height: 42)
            
            RoundedRectLine(width: 64, height: 12, cornerRadius: 6)
            RoundedRectLine(width: 48, height: 12, cornerRadius: 6)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(SkeletonFill())
        )
    }
    
    private func sectionHeaderSkeleton(
        titleWidth: CGFloat,
        subtitleWidth: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectLine(width: titleWidth, height: 18, cornerRadius: 7)
            RoundedRectLine(width: subtitleWidth, height: 14, cornerRadius: 7)
        }
    }
    
    private var filterPillSkeleton: some View {
        RoundedRectangle(cornerRadius: 999, style: .continuous)
            .fill(SkeletonFill())
            .frame(maxWidth: .infinity)
            .frame(height: 38)
    }
    
    private var sectionBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 18 / 255, green: 24 / 255, blue: 42 / 255).opacity(0.75),
                Color(red: 19 / 255, green: 30 / 255, blue: 56 / 255).opacity(0.65)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var sectionBorder: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.42),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
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

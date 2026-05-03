import SwiftUI
import GymbroCommonUI

struct ChallengeLeaderboardViewStub: View {
    
    var body: some View {
        ZStack {
            backgroundView
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    topBar
                    headerSkeleton
                    podiumSkeleton
                    allTeamsSkeleton
                }
                .padding(.horizontal, 15)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .shimmer(active: true)
    }
    
    private var topBar: some View {
        HStack {
            Circle()
                .fill(SkeletonFill())
                .frame(width: 42, height: 42)
            
            Spacer()
            
            RoundedRectLine(width: 130, height: 24, cornerRadius: 8)
            
            Spacer()
            
            Circle()
                .fill(Color.clear)
                .frame(width: 42, height: 42)
        }
    }
    
    private var headerSkeleton: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(SkeletonFill())
                .frame(width: 58, height: 58)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectLine(width: 210, height: 30, cornerRadius: 10)
                RoundedRectLine(width: 280, height: 14, cornerRadius: 7)
                RoundedRectLine(width: 220, height: 14, cornerRadius: 7)
            }
        }
    }
    
    private var podiumSkeleton: some View {
        VStack(alignment: .leading, spacing: 13) {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectLine(width: 120, height: 23, cornerRadius: 8)
                RoundedRectLine(width: 210, height: 13, cornerRadius: 7)
            }
            
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    podiumCardSkeleton
                }
            }
        }
    }
    
    private var podiumCardSkeleton: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                Circle()
                    .fill(SkeletonFill())
                    .frame(width: 58, height: 58)
                
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectLine(width: 170, height: 18, cornerRadius: 7)
                    RoundedRectLine(width: 90, height: 13, cornerRadius: 6)
                }
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(SkeletonFill())
                    .frame(width: 44, height: 44)
            }
            
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(SkeletonFill())
                .frame(height: 10)
            
            HStack {
                pill(width: 90)
                Spacer()
                RoundedRectLine(width: 22, height: 14, cornerRadius: 6)
            }
        }
        .padding(18)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
    
    private var allTeamsSkeleton: some View {
        VStack(alignment: .leading, spacing: 13) {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectLine(width: 110, height: 22, cornerRadius: 8)
                RoundedRectLine(width: 230, height: 13, cornerRadius: 7)
            }
            
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    teamRowSkeleton
                }
            }
        }
    }
    
    private var teamRowSkeleton: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 12) {
                RoundedRectLine(width: 34, height: 15, cornerRadius: 6)
                
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(SkeletonFill())
                    .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 7) {
                    RoundedRectLine(width: 150, height: 16, cornerRadius: 7)
                    RoundedRectLine(width: 88, height: 12, cornerRadius: 6)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    RoundedRectLine(width: 42, height: 15, cornerRadius: 6)
                    RoundedRectLine(width: 72, height: 12, cornerRadius: 6)
                }
            }
            
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(SkeletonFill())
                .frame(height: 10)
            
            HStack {
                pill(width: 90)
                Spacer()
            }
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    private func pill(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 999, style: .continuous)
            .fill(SkeletonFill())
            .frame(width: width, height: 30)
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

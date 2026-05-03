import SwiftUI
import GymbroCommonUI

struct JoinChallengeViewStub: View {
    
    var body: some View {
        ZStack {
            backgroundView
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    topBar
                    headerSkeleton
                    summarySkeleton
                    teamsSkeleton
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
            
            RoundedRectLine(width: 52, height: 24, cornerRadius: 8)
            
            Spacer()
            
            Circle()
                .fill(Color.clear)
                .frame(width: 42, height: 42)
        }
    }
    
    private var headerSkeleton: some View {
        VStack(alignment: .leading, spacing: 14) {
            Circle()
                .fill(SkeletonFill())
                .frame(width: 58, height: 58)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectLine(width: 210, height: 30, cornerRadius: 10)
                RoundedRectLine(width: 310, height: 14, cornerRadius: 7)
                RoundedRectLine(width: 250, height: 14, cornerRadius: 7)
            }
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
    
    private var summarySkeleton: some View {
        HStack(spacing: 10) {
            summaryPill
            summaryPill
        }
    }
    
    private var summaryPill: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(SkeletonFill())
                .frame(width: 42, height: 42)
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectLine(width: 30, height: 20, cornerRadius: 7)
                RoundedRectLine(width: 84, height: 12, cornerRadius: 6)
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white.opacity(0.055))
        )
    }
    
    private var teamsSkeleton: some View {
        VStack(alignment: .leading, spacing: 13) {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectLine(width: 150, height: 23, cornerRadius: 8)
                RoundedRectLine(width: 255, height: 13, cornerRadius: 7)
            }
            
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    teamCardSkeleton
                }
            }
        }
    }
    
    private var teamCardSkeleton: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(SkeletonFill())
                .frame(width: 54, height: 54)
            
            VStack(alignment: .leading, spacing: 7) {
                RoundedRectLine(width: 160, height: 17, cornerRadius: 7)
                RoundedRectLine(width: 90, height: 13, cornerRadius: 6)
            }
            
            Spacer()
            
            RoundedRectLine(width: 14, height: 18, cornerRadius: 5)
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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

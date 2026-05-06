import SwiftUI
import GymbroCommonUI

struct FeedsViewStub: View {

    var topSafeInset: CGFloat = 0

    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 0) {
                topBar
                    .padding(.top, topSafeInset + 4)
                    .padding(.bottom, 18)
                
                segmentRow
                    .padding(.horizontal, 11)
                    .padding(.bottom, 18)
                
                communitiesRow
                    .padding(.bottom, 20)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 15) {
                        ForEach(0..<4, id: \.self) { index in
                            postCardSkeleton(
                                hasLocation: index != 1,
                                hasShowMore: index == 0 || index == 2
                            )
                        }
                    }
                    .padding(.horizontal, 7)
                    .padding(.bottom, 120)
                }
            }
        }
        .shimmer(active: true)
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 12/255, green: 18/255, blue: 36/255),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var topBar: some View {
        HStack {
            Circle()
                .fill(SkeletonFill())
                .frame(width: 48, height: 48)
            
            Spacer()
            
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(SkeletonFill())
                    .frame(width: 52, height: 52)
                
                RoundedRectLine(width: 88, height: 26, cornerRadius: 8)
            }
            
            Spacer()
            
            Circle()
                .fill(SkeletonFill())
                .frame(width: 48, height: 48)
        }
        .padding(.horizontal, 20)
    }
    
    private var segmentRow: some View {
        HStack(spacing: 10) {
            segmentPill(width: 78)
            segmentPill(width: 82)
            segmentPill(width: 78)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func segmentPill(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(SkeletonFill())
            .frame(width: width, height: 38)
    }
    
    private var communitiesRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(0..<5, id: \.self) { index in
                    communityBubble
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var communityBubble: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(SkeletonFill())
                    .frame(width: 82, height: 82)
            }
            
            RoundedRectLine(width: 62, height: 12, cornerRadius: 6)
        }
    }
    
    private func postCardSkeleton(hasLocation: Bool, hasShowMore: Bool) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            postHeaderSkeleton
            coverSkeleton
            postContentSkeleton(hasLocation: hasLocation, hasShowMore: hasShowMore)
        }
        .padding(18)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
    
    private var postHeaderSkeleton: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(SkeletonFill())
                .frame(width: 56, height: 56)
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectLine(width: 120, height: 16, cornerRadius: 6)
                RoundedRectLine(width: 72, height: 12, cornerRadius: 6)
            }
            
            Spacer()
            
            Circle()
                .fill(SkeletonFill())
                .frame(width: 30, height: 30)
        }
    }
    
    private var coverSkeleton: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(SkeletonFill())
            .frame(height: 220)
    }
    
    private func postContentSkeleton(hasLocation: Bool, hasShowMore: Bool) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectLine(width: 190, height: 24, cornerRadius: 8)
            
            HStack(spacing: 10) {
                metaPill(width: 76)
                metaPill(width: 72)
                metaPill(width: 90)
            }
            
            if hasLocation {
                HStack(spacing: 8) {
                    Circle()
                        .fill(SkeletonFill())
                        .frame(width: 14, height: 14)
                    RoundedRectLine(width: 150, height: 12, cornerRadius: 6)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectLine(width: 260, height: 14, cornerRadius: 6)
                RoundedRectLine(width: 220, height: 14, cornerRadius: 6)
            }
            
            RoundedRectLine(width: 88, height: 12, cornerRadius: 6)
            
            VStack(spacing: 12) {
                exerciseRowSkeleton
                exerciseRowSkeleton
                
                if hasShowMore {
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(SkeletonFill())
                        .frame(height: 42)
                }
            }
            
            Divider()
                .overlay(Color.white.opacity(0.08))
            
            HStack(spacing: 24) {
                actionSkeleton(width: 44)
                actionSkeleton(width: 44)
                Spacer()
            }
        }
    }
    
    private func metaPill(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 999, style: .continuous)
            .fill(SkeletonFill())
            .frame(width: width, height: 36)
    }
    
    private var exerciseRowSkeleton: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(SkeletonFill())
                .frame(width: 72, height: 72)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectLine(width: 150, height: 14, cornerRadius: 6)
                RoundedRectLine(width: 88, height: 12, cornerRadius: 6)
            }
            
            Spacer()
            
            RoundedRectLine(width: 10, height: 16, cornerRadius: 4)
        }
        .padding(14)
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
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private func actionSkeleton(width: CGFloat) -> some View {
        RoundedRectLine(width: width, height: 16, cornerRadius: 6)
    }
    
    private var cardBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 18/255, green: 24/255, blue: 42/255).opacity(0.75),
                Color(red: 19/255, green: 30/255, blue: 56/255).opacity(0.65)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

import SwiftUI
import GymbroCommonUI

struct WorkoutsListViewStub: View {
    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.bottom, 12)


            secondRow
                .padding(.horizontal, 16)
                .padding(.bottom, 15)


            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(0..<8, id: \.self) { _ in
                        workoutCardSkeleton
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .shimmer(active: true)
    }


    // MARK: - Header


    private var header: some View {
        HStack(alignment: .center, spacing: 0) {
            RoundedRectLine(width: 190, height: 34, cornerRadius: 8)
                .padding(.top, 16)
                .padding(.leading, 16)
                .padding(.bottom, 12)


            Spacer(minLength: 12)

            HStack(spacing: 6) {
                RoundedRectLine(width: 25, height: 25, cornerRadius: 6)
                RoundedRectLine(width: 22, height: 20, cornerRadius: 6)
            }
            .padding(8)
            .background(SkeletonFill())
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.top, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 12)
        }
    }

    private var secondRow: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(SkeletonFill())
                .frame(width: 44, height: 44)
                .overlay(
                    RoundedRectLine(width: 21, height: 21, cornerRadius: 6)
                )

            HStack(spacing: 10) {
                RoundedRectLine(width: 22, height: 22, cornerRadius: 6)
                RoundedRectLine(width: 160, height: 16, cornerRadius: 6)
                Spacer(minLength: 0)
            }
            .padding(7)
            .background(SkeletonFill())
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(height: 44)
        }
    }



    private var workoutCardSkeleton: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                RoundedRectLine(width: 190, height: 22, cornerRadius: 7)
                RoundedRectLine(width: 90, height: 12, cornerRadius: 6)
                    .padding(.top, 1)
            }


            Spacer(minLength: 12)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 2)
                .frame(width: 72, height: 72)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(SkeletonFill())
                        .padding(4)
                )
        }
        .padding(15)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.30),
                    Color.white.opacity(0.25)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

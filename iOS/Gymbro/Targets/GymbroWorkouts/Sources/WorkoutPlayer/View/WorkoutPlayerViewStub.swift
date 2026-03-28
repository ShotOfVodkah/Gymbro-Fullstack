import SwiftUI
import GymbroCommonUI

struct WorkoutPlayerViewStub: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 16)

            exerciseCard
                .padding(.horizontal, 16)
                .padding(.top, 12)

            upNext
                .padding(.top, 20)
                .padding(.horizontal, 16)

            progressBar
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 0) {
                RoundedRectLine(width: 12, height: 20, cornerRadius: 4)

                RoundedRectLine(width: 180, height: 28, cornerRadius: 7)
                    .padding(.leading, 24)
            }

            RoundedRectLine(width: 90, height: 15, cornerRadius: 6)
                .padding(.leading, 36)

            RoundedRectLine(width: 48, height: 15, cornerRadius: 6)
                .padding(.leading, 36)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Exercise card

    private var exerciseCard: some View {
        VStack(spacing: 12) {
            Spacer()

            VStack(spacing: 10) {
                RoundedRectLine(width: 210, height: 28, cornerRadius: 8)

                RoundedRectLine(width: 110, height: 28, cornerRadius: 14)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.10))
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )
            }

            Spacer()

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.14))
                .frame(width: 180, height: 180)

            Spacer()

            HStack(spacing: 8) {
                statCapsule
                statCapsule
                statCapsule
            }
        }
        .padding(.all, 25)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 35, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color.white.opacity(0.18), Color.white.opacity(0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.40), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }

    private var statCapsule: some View {
        VStack(spacing: 8) {
            RoundedRectLine(width: 50, height: 13, cornerRadius: 6)
            RoundedRectLine(width: 36, height: 13, cornerRadius: 6)
        }
        .padding(.all, 10)
        .frame(maxWidth: .infinity)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.10))
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - Up Next

    private var upNext: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectLine(width: 58, height: 14, cornerRadius: 6)
                RoundedRectLine(width: 150, height: 20, cornerRadius: 7)
            }
            Spacer()
            RoundedRectLine(width: 10, height: 20, cornerRadius: 4)
        }
        .padding(.all, 10)
        .frame(maxWidth: .infinity, minHeight: 70)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Progress bar

    private var progressBar: some View {
        Capsule(style: .continuous)
            .fill(Color.white.opacity(0.15))
            .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
            .frame(height: 6)
    }
}

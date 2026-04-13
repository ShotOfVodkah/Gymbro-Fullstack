import SwiftUI

import GymbroCommonUI

struct WorkoutLoadingCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectLine(width: 160, height: 18, cornerRadius: 8)
            RoundedRectLine(width: 220, height: 14, cornerRadius: 6)
            Divider().overlay(Color.white.opacity(0.06))
            skeletonRow(wide: true)
            skeletonRow(wide: false)
            skeletonRow(wide: true)
            skeletonRow(wide: false)
            skeletonRow(wide: true)
            Spacer()
            RoundedRectLine(width: 220, height: 50, cornerRadius: 25)
                .frame(maxWidth: .infinity, alignment: .center)
            RoundedRectLine(width: 130, height: 13, cornerRadius: 5)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxHeight: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appDarkGray)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .shimmer(active: true)
    }

    private func skeletonRow(wide: Bool) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectLine(width: wide ? 180 : 130, height: 13, cornerRadius: 5)
                RoundedRectLine(width: 100, height: 11, cornerRadius: 4)
            }
        }
        .padding(.horizontal, 8)
    }
}

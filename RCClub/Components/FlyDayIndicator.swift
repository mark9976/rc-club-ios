import SwiftUI

struct FlyDayIndicator: View {
    let rating: FlyDayRating
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(rating.color)
                .frame(width: compact ? 8 : 10, height: compact ? 8 : 10)
            Text(rating.label)
                .font(compact ? .caption.weight(.semibold) : .subheadline.weight(.semibold))
                .foregroundStyle(rating.color)
        }
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 4 : 6)
        .background(rating.color.opacity(0.12), in: Capsule())
    }
}

import SwiftUI

struct NextEventCard: View {
    let event: Event

    var body: some View {
        NavigationLink(value: event) {
            CardView {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentTeal.opacity(0.15))
                        .frame(width: 48, height: 48)
                        .overlay {
                            Image(systemName: "calendar")
                                .foregroundStyle(Color.accentTeal)
                        }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Next Event")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(event.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(event.date.asDate?.mediumDateString ?? event.date)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

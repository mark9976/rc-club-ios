import SwiftUI

struct CommunityStatusView: View {
    let count: Int
    let isCheckedIn: Bool
    let onToggle: () -> Void

    var body: some View {
        CardView {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Community")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("\(count) at the field")
                            .font(.title2.bold())
                    }
                    Spacer()
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.accentTeal)
                }

                Button {
                    onToggle()
                } label: {
                    Label(
                        isCheckedIn ? "Leave Field" : "I'm at the Field",
                        systemImage: isCheckedIn ? "figure.walk.departure" : "mappin.and.ellipse"
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(isCheckedIn ? Color.dangerRed : Color.accentTeal)
                .controlSize(.large)
            }
        }
    }
}

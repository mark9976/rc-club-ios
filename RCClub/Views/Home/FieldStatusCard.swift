import SwiftUI

struct FieldStatusCard: View {
    let status: FieldStatus
    let isCheckedIn: Bool
    let isToggling: Bool
    let onToggle: () -> Void

    var body: some View {
        CardView {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Field Status")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(status.isOpen ? "OPEN" : "CLOSED")
                        .font(.largeTitle.bold())
                        .foregroundStyle(status.isOpen ? Color.successGreen : Color.dangerRed)
                    if let reason = status.reason, !status.isOpen {
                        Text(reason)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: status.isOpen ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(status.isOpen ? Color.successGreen : Color.dangerRed)
            }

            Divider()

            HStack {
                Label("\(status.checkedInCount) at the field now", systemImage: "person.2.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    onToggle()
                } label: {
                    if isToggling {
                        ProgressView().tint(.white)
                    } else {
                        Text(isCheckedIn ? "Check Out" : "Check In")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(isCheckedIn ? Color.dangerRed : Color.accentTeal)
                .disabled(isToggling)
            }
        }
    }
}

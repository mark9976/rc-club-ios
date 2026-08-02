import SwiftUI

enum QuickBroadcast: String, CaseIterable, Identifiable {
    case atField = "I'm at the field"
    case headingToField = "Heading to the field"
    case anyoneFly = "Anyone want to fly?"

    var id: String { rawValue }
}

struct QuickBroadcastButtons: View {
    let onSelect: (QuickBroadcast) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(QuickBroadcast.allCases) { option in
                    Button(option.rawValue) {
                        Haptics.tap()
                        onSelect(option)
                    }
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.accentTeal.opacity(0.12), in: Capsule())
                    .foregroundStyle(Color.accentTeal)
                }
            }
            .padding(.horizontal, 1)
        }
        .scrollClipDisabled()
    }
}

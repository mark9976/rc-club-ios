import SwiftUI

extension Color {
    static let primaryNavy = Color(red: 0.071, green: 0.122, blue: 0.169)
    static let accentTeal = Color(red: 0.0, green: 0.541, blue: 0.635)
    static let successGreen = Color(red: 0.204, green: 0.780, blue: 0.349)
    static let warningOrange = Color(red: 1.0, green: 0.584, blue: 0.0)
    static let dangerRed = Color(red: 1.0, green: 0.231, blue: 0.188)

    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let screenBackground = Color(uiColor: .systemGroupedBackground)
}

extension FlyDayRating {
    var color: Color {
        switch self {
        case .good: .successGreen
        case .marginal: .warningOrange
        case .poor: .dangerRed
        }
    }

    var label: String {
        switch self {
        case .good: "Good"
        case .marginal: "Marginal"
        case .poor: "Poor"
        }
    }
}

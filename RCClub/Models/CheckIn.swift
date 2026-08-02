import Foundation

struct CheckIn: Codable, Sendable {
    let userId: Int
    let checkedInAt: String
    let expiresAt: String
}

struct CheckInCount: Codable, Sendable {
    let count: Int
}

/// Local mirror of "am I checked in", since the server doesn't expose a
/// dedicated "my status" endpoint. Mirrors the server's 11 PM nightly expiry.
struct CheckInLocalState: Codable, Sendable {
    let checkedIn: Bool
    let setAt: Date

    var isExpired: Bool {
        let calendar = Calendar.current
        guard calendar.isDate(setAt, inSameDayAs: Date()) else { return true }
        guard let cutoff = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: Date()) else { return false }
        return Date() >= cutoff
    }
}

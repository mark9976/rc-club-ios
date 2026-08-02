import Foundation

extension ISO8601DateFormatter {
    // Configured once and only ever read from afterward, so it's safe to share
    // across isolation domains despite Foundation not marking it Sendable.
    nonisolated(unsafe) static let rcclub = ISO8601DateFormatter()
    nonisolated(unsafe) static let rcclubWithFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

extension DateFormatter {
    static let rcclubDateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension String {
    /// Parses the ISO 8601 (with or without fractional seconds) or plain
    /// `yyyy-MM-dd` strings the server sends for dates and timestamps.
    var asDate: Date? {
        ISO8601DateFormatter.rcclubWithFractional.date(from: self)
            ?? ISO8601DateFormatter.rcclub.date(from: self)
            ?? DateFormatter.rcclubDateOnly.date(from: self)
    }
}

extension Date {
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var timeOfDayString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    var mediumDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }

    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
}

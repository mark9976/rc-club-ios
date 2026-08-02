import Foundation

struct NotificationPreferences: Codable, Equatable, Sendable {
    var fieldStatus: Bool
    var events: Bool
    var lessons: Bool
    var groupMessages: Bool
    var newsletters: Bool
    var duesReminders: Bool
    var classifieds: Bool
    var photos: Bool

    static let defaults = NotificationPreferences(
        fieldStatus: true,
        events: true,
        lessons: true,
        groupMessages: true,
        newsletters: true,
        duesReminders: true,
        classifieds: false,
        photos: false
    )
}

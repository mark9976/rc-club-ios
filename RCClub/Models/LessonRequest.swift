import Foundation

struct LessonRequest: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let studentId: Int
    let studentName: String
    let type: String
    let experienceLevel: String
    let preferredTimes: String?
    let notes: String?
    let status: String // "pending", "accepted", "scheduled", "completed"
    let instructorId: Int?
    let instructorName: String?
    let scheduledDate: String?
    let createdAt: String
}

enum LessonType: String, CaseIterable, Identifiable, Sendable {
    case fixedWing = "fixed_wing"
    case helicopter
    case multiRotor = "multi_rotor"
    case float
    case jet

    var id: String { rawValue }
    var label: String {
        switch self {
        case .fixedWing: "Fixed Wing"
        case .helicopter: "Helicopter"
        case .multiRotor: "Multi-Rotor"
        case .float: "Float"
        case .jet: "Jet"
        }
    }
}

enum ExperienceLevel: String, CaseIterable, Identifiable, Sendable {
    case beginner, intermediate, advanced
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

enum LessonStatus: String, Sendable {
    case pending, accepted, scheduled, completed
}

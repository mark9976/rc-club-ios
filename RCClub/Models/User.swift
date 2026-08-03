import Foundation

struct User: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let email: String
    let role: String // "member", "admin", "instructor"
    let profilePhoto: String?
    let memberSince: String?
    let amaNumber: String?

    var isAdmin: Bool { role == "admin" }
    var isInstructor: Bool { role == "instructor" || role == "admin" }
}

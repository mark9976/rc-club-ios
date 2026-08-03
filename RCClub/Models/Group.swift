import Foundation

struct RCGroup: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let memberCount: Int
    let createdBy: String
    let unreadCount: Int?
}

struct GroupMember: Codable, Identifiable, Sendable {
    let id: Int
    let userId: String
    let name: String
    let isCheckedIn: Bool
}

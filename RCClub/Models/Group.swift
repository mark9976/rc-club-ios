import Foundation

struct RCGroup: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let createdBy: String
    let createdByName: String
    let createdAt: String
    // Only present in the list response — create/rename/detail omit it.
    let memberCount: Int?
    // Not tracked by the server at all yet — always nil for now.
    let unreadCount: Int?
}

struct GroupMember: Codable, Sendable {
    let userId: String
    let userName: String
    let joinedAt: String?
    let isCheckedIn: Bool
}

extension GroupMember: Identifiable {
    // The server has no separate member-row id — userId is already unique per group.
    var id: String { userId }
}

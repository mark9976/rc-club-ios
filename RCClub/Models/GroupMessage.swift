import Foundation

struct GroupMessage: Codable, Identifiable, Sendable {
    let id: Int
    let groupId: Int
    let senderId: String
    let senderName: String
    let text: String
    let isBroadcast: Bool
    let sentAt: String
}

import Foundation

struct GroupMessage: Codable, Identifiable, Sendable {
    let id: String
    let groupId: String
    let senderId: String
    let senderName: String
    let text: String
    let isBroadcast: Bool
    let sentAt: String
}

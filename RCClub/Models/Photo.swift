import Foundation

struct Photo: Codable, Identifiable, Sendable {
    let id: Int
    let filename: String
    let url: String
    let uploadedBy: String
    let status: String // "pending", "approved", "rejected"
    let createdAt: String
}

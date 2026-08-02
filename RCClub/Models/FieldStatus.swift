import Foundation

struct FieldStatus: Codable, Sendable {
    let isOpen: Bool
    let reason: String?
    let updatedAt: String
    let checkedInCount: Int
}

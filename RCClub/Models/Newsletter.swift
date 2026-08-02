import Foundation

struct Newsletter: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let date: String
    let fileUrl: String
}

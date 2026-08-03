import Foundation

struct Newsletter: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let date: String
    let fileUrl: String
}

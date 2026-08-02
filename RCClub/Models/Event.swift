import Foundation

struct Event: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let date: String
    let time: String?
    let location: String?
    let description: String?
}

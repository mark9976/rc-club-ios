import Foundation

struct Event: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let date: String
    let time: String?
    let location: String?
    let description: String?

    private enum CodingKeys: String, CodingKey {
        case id, title, date, time, location
        case description = "desc"
    }
}

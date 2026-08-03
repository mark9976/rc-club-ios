import Foundation

struct Newsletter: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let date: String

    private enum CodingKeys: String, CodingKey {
        case id, title
        case date = "issueDate"
    }

    /// The server only gives back a bare `filename` — build the actual
    /// download URL from the newsletter's id against the active club's server.
    var fileUrl: String {
        APIClient.shared.fileURL("/api/newsletters/file/\(id)")?.absoluteString ?? ""
    }
}

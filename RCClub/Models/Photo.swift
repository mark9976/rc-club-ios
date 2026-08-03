import Foundation

struct Photo: Codable, Identifiable, Sendable {
    let id: String
    let filename: String
    let uploadedBy: String
    let status: String // "pending", "approved", "rejected"
    let createdAt: String

    private enum CodingKeys: String, CodingKey {
        case id, filename, status
        case uploadedBy = "submitter"
        case createdAt = "submitted"
    }

    /// The server only gives back a bare `filename` — build the full URL
    /// against the active club's server rather than decoding one directly.
    var url: String {
        APIClient.shared.fileURL("/api/photos/files/\(filename)")?.absoluteString ?? ""
    }
}

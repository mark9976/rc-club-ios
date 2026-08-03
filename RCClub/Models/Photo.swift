import Foundation

struct Photo: Identifiable, Sendable {
    let id: String
    let filename: String
    let uploadedBy: String
    let status: String // "pending", "approved", "rejected"
    let createdAt: String
}

extension Photo: Codable {
    // The server uses different field names depending on approval state:
    // pending/upload responses use submitter/submitted/status, while
    // approved responses (recent + approve) use photographer/date/approvedAt
    // and omit status entirely. Decode leniently across both shapes.
    private enum CodingKeys: String, CodingKey {
        case id, filename, status
        case submitter, submitted
        case photographer, date, approvedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        filename = try container.decode(String.self, forKey: .filename)
        uploadedBy = try container.decodeIfPresent(String.self, forKey: .submitter)
            ?? container.decodeIfPresent(String.self, forKey: .photographer)
            ?? ""
        createdAt = try container.decodeIfPresent(String.self, forKey: .submitted)
            ?? container.decodeIfPresent(String.self, forKey: .approvedAt)
            ?? container.decodeIfPresent(String.self, forKey: .date)
            ?? ""
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "approved"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(filename, forKey: .filename)
        try container.encode(uploadedBy, forKey: .submitter)
        try container.encode(createdAt, forKey: .submitted)
        try container.encode(status, forKey: .status)
    }

    /// The server serves files by id, not filename (confirmed via the
    /// approve endpoint's own `src` field: "/api/photos/files/{id}").
    var url: String {
        APIClient.shared.fileURL("/api/photos/files/\(id)")?.absoluteString ?? ""
    }
}

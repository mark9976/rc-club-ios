import Foundation

struct FieldStatus: Sendable {
    let isOpen: Bool
    let reason: String?
    let updatedAt: String
    let checkedInCount: Int
}

extension FieldStatus: Decodable {
    // The server nests the actual status under `fieldStatus` and represents
    // it as a string ("open"/"closed") rather than a flat boolean, e.g.:
    // {"checkedInCount":0,"fieldStatus":{"status":"open","reason":"","updatedAt":"..."}}
    private enum TopLevelKeys: String, CodingKey {
        case checkedInCount
        case fieldStatus
    }

    private enum StatusKeys: String, CodingKey {
        case status
        case reason
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TopLevelKeys.self)
        checkedInCount = try container.decodeIfPresent(Int.self, forKey: .checkedInCount) ?? 0

        let statusContainer = try container.nestedContainer(keyedBy: StatusKeys.self, forKey: .fieldStatus)
        let statusString = try statusContainer.decode(String.self, forKey: .status)
        isOpen = statusString.lowercased() == "open"

        let rawReason = try statusContainer.decodeIfPresent(String.self, forKey: .reason)
        reason = (rawReason?.isEmpty ?? true) ? nil : rawReason
        updatedAt = try statusContainer.decode(String.self, forKey: .updatedAt)
    }
}

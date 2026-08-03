import Foundation

struct User: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let email: String
    let role: String // "member", "admin", "instructor"
    let profilePhoto: String?
    let memberSince: String?
    let amaNumber: String?

    var isAdmin: Bool { role == "admin" }
    var isInstructor: Bool { role == "instructor" || role == "admin" }
}

extension User: Codable {
    // The member-search variant of /api/members (with ?search=) returns a much
    // leaner shape — just {id, name} — than the full roster or login response.
    // Decode leniently so that doesn't fail outright.
    private enum CodingKeys: String, CodingKey {
        case id, name, email, role, profilePhoto, memberSince, amaNumber
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        role = try container.decodeIfPresent(String.self, forKey: .role) ?? "member"
        profilePhoto = try container.decodeIfPresent(String.self, forKey: .profilePhoto)
        memberSince = try container.decodeIfPresent(String.self, forKey: .memberSince)
        amaNumber = try container.decodeIfPresent(String.self, forKey: .amaNumber)
    }
}

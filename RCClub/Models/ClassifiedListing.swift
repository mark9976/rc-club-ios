import Foundation

struct ClassifiedListing: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let price: String?
    let category: String
    let description: String
    let photos: [String]
    let sellerName: String
    let sellerId: String
    let isSold: Bool
    let createdAt: String
}

extension ClassifiedListing: Decodable {
    // The list endpoint uses ownerId/ownerName instead of sellerId/sellerName,
    // price as a string rather than a number, and doesn't include photo URLs
    // or a sold flag at all (only a `hasPhoto` count) — this decodes leniently
    // so a missing/renamed field degrades gracefully instead of failing outright.
    private enum CodingKeys: String, CodingKey {
        case id, title, price, category, description, photos, createdAt
        case sellerName = "ownerName"
        case sellerId = "ownerId"
        case isSold, sold
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        price = try container.decodeIfPresent(String.self, forKey: .price)
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "other"
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        photos = try container.decodeIfPresent([String].self, forKey: .photos) ?? []
        sellerName = try container.decodeIfPresent(String.self, forKey: .sellerName) ?? ""
        sellerId = try container.decodeIfPresent(String.self, forKey: .sellerId) ?? ""
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        isSold = try container.decodeIfPresent(Bool.self, forKey: .isSold)
            ?? container.decodeIfPresent(Bool.self, forKey: .sold)
            ?? false
    }
}

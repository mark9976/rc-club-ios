import Foundation

struct ClassifiedListing: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let price: Double?
    let category: String
    let description: String
    let photos: [String] // URLs
    let sellerName: String
    let sellerId: String
    let isSold: Bool
    let createdAt: String
}

enum ClassifiedCategory: String, CaseIterable, Identifiable, Sendable {
    case planes, radios, engines, accessories, other
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

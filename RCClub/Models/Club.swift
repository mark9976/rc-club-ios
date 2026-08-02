import Foundation

struct Club: Codable, Identifiable, Hashable, Sendable {
    let id: String // club code
    let name: String
    let server: String
    let logo: String?
}

struct ClubRegistryResponse: Codable, Sendable {
    let clubs: [ClubRegistryEntry]
}

struct ClubRegistryEntry: Codable, Sendable {
    let code: String
    let name: String
    let server: String
    let logo: String?

    var asClub: Club {
        Club(id: code, name: name, server: server, logo: logo)
    }
}

struct ClubConfig: Codable, Sendable {
    let name: String
    let logo: String?
    let primaryColorHex: String?
    let accentColorHex: String?
    let fieldLatitude: Double?
    let fieldLongitude: Double?
    let fieldAddress: String?
    let website: String?
}

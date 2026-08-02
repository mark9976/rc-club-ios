import Foundation

/// Fetches and caches the list of clubs the app can connect to. Hosted as a
/// static JSON file so new clubs can be added without an app update.
@MainActor
final class ClubRegistry {
    static let shared = ClubRegistry()
    private init() {}

    private let registryURL = URL(
        string: "https://raw.githubusercontent.com/mark9976/rc-club-ios/main/registry/clubs.json"
    )!

    private(set) var cachedClubs: [Club] = []

    func fetchClubs() async throws -> [Club] {
        let (data, response) = try await URLSession.shared.data(from: registryURL)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.server(
                status: (response as? HTTPURLResponse)?.statusCode ?? 0,
                message: "Couldn't load the club directory."
            )
        }
        let decoded = try JSONDecoder().decode(ClubRegistryResponse.self, from: data)
        let clubs = decoded.clubs.map(\.asClub).sorted { $0.name < $1.name }
        cachedClubs = clubs
        return clubs
    }

    func findClub(byCode code: String, in clubs: [Club]) -> Club? {
        clubs.first { $0.id.caseInsensitiveCompare(code) == .orderedSame }
    }
}

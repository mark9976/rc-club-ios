import Foundation

struct AuthToken: Codable, Sendable {
    let token: String
    let user: User
}

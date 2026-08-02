import Foundation

struct AuthToken: Codable, Sendable {
    let token: String
    let expiresAt: String
    let user: User
}

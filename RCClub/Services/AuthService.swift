import Foundation

@MainActor
final class AuthService {
    static let shared = AuthService()
    private init() {}

    private struct LoginBody: Encodable { let username: String; let password: String }
    private struct ChangePasswordBody: Encodable { let oldPassword: String; let newPassword: String }

    func login(clubId: String, baseURL: String, username: String, password: String) async throws -> User {
        APIClient.shared.configure(baseURL: baseURL, token: nil)
        let auth: AuthToken = try await APIClient.shared.post(
            "/api/auth/login",
            body: LoginBody(username: username, password: password)
        )
        KeychainHelper.shared.saveToken(auth.token, forClub: clubId)
        APIClient.shared.updateToken(auth.token)
        return auth.user
    }

    func validateSession() async throws -> User {
        try await APIClient.shared.get("/api/auth/session")
    }

    func logout(clubId: String) async {
        let _: Empty? = try? await APIClient.shared.post("/api/auth/logout")
        KeychainHelper.shared.deleteToken(forClub: clubId)
        APIClient.shared.updateToken(nil)
        await PushNotificationService.shared.unregisterDevice()
    }

    func changePassword(oldPassword: String, newPassword: String) async throws {
        let _: Empty = try await APIClient.shared.put(
            "/api/auth/change-password",
            body: ChangePasswordBody(oldPassword: oldPassword, newPassword: newPassword)
        )
    }
}

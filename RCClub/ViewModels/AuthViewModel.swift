import Foundation
import Observation

@Observable
@MainActor
final class AuthViewModel {
    var username = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?

    func login(club: Club, appState: AppState) async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Enter your username and password."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let user = try await AuthService.shared.login(
                clubId: club.id,
                baseURL: club.server,
                username: username,
                password: password
            )
            appState.completeLogin(user: user)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

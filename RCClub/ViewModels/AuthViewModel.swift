import Foundation
import Observation

@Observable
@MainActor
final class AuthViewModel {
    var username = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?

    /// Set after a successful manual login but held back from AppState until
    /// the "enable Face ID?" opt-in prompt (if any) has been resolved — completing
    /// login immediately would navigate away from LoginView before the user could answer.
    var pendingUser: User?

    func signInWithBiometrics(appState: AppState) async {
        isLoading = true
        errorMessage = nil
        let reason = "Sign in to RC Club"
        guard await BiometricAuthService.authenticate(reason: reason) else {
            isLoading = false
            return
        }
        let success = await appState.completeBiometricSignIn()
        if !success {
            errorMessage = "Your saved session has expired. Please sign in again."
        }
        isLoading = false
    }

    func login(club: Club) async {
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
            pendingUser = user
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

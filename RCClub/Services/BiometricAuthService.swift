import LocalAuthentication

/// App-lock via Face ID/Touch ID over an already-signed-in session — there's
/// no password stored client-side to "unlock" for the initial login itself.
@MainActor
enum BiometricAuthService {
    enum Kind {
        case none, touchID, faceID

        var label: String {
            switch self {
            case .none: "Passcode"
            case .touchID: "Touch ID"
            case .faceID: "Face ID"
            }
        }

        var systemImage: String {
            switch self {
            case .none: "lock.fill"
            case .touchID: "touchid"
            case .faceID: "faceid"
            }
        }
    }

    /// What biometry hardware is enrolled and available right now — used to
    /// decide whether to even show the Settings toggle.
    static var availableKind: Kind {
        let context = LAContext()
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            return .none
        }
        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        default: return .none
        }
    }

    /// Prompts for biometrics, falling back to device passcode if biometry
    /// fails or isn't available — standard iOS app-lock UX.
    static func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else {
            return false
        }
        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
        } catch {
            return false
        }
    }
}

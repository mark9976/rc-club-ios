import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    var clubConfig: ClubConfig?
    var notificationPreferences: NotificationPreferences = .defaults
    var isLoading = false
    var isSavingPreferences = false
    var errorMessage: String?

    var locationEnabled: Bool {
        get { LocationService.shared.isEnabled }
        set { LocationService.shared.isEnabled = newValue }
    }

    func loadAll() async {
        isLoading = true
        errorMessage = nil
        async let configTask: ClubConfig? = try? APIClient.shared.get("/api/club-config")
        async let prefsTask: NotificationPreferences? = try? APIClient.shared.get("/api/push/preferences")
        clubConfig = await configTask
        notificationPreferences = await prefsTask ?? .defaults
        if let config = clubConfig, let lat = config.fieldLatitude, let lon = config.fieldLongitude {
            LocationService.shared.configure(fieldLatitude: lat, fieldLongitude: lon)
        }
        isLoading = false
    }

    func savePreferences() async {
        isSavingPreferences = true
        defer { isSavingPreferences = false }
        do {
            try await PushNotificationService.shared.updatePreferences(notificationPreferences)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func changePassword(oldPassword: String, newPassword: String) async -> Bool {
        do {
            try await AuthService.shared.changePassword(oldPassword: oldPassword, newPassword: newPassword)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

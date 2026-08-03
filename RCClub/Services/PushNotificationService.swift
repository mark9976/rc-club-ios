import Foundation
import UserNotifications
import UIKit

@MainActor
final class PushNotificationService {
    static let shared = PushNotificationService()
    private init() {}

    private var didRequestAuthorization = false
    private var pendingDeviceToken: String?

    func requestAuthorizationIfNeeded() async {
        guard !didRequestAuthorization else { return }
        didRequestAuthorization = true
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }
        } catch {
            print("Notification authorization error: \(error)")
        }
    }

    /// Called from the app delegate once APNs hands back a device token.
    func didReceiveDeviceToken(_ token: String, userId: String?) {
        pendingDeviceToken = token
        guard let userId else { return }
        Task { await registerDeviceToken(token, userId: userId) }
    }

    /// Called after login in case the device token arrived before the user signed in.
    func registerCurrentDeviceIfNeeded(userId: String) {
        guard let token = pendingDeviceToken else { return }
        Task { await registerDeviceToken(token, userId: userId) }
    }

    private func registerDeviceToken(_ token: String, userId: String) async {
        struct Body: Encodable { let deviceToken: String; let platform: String; let userId: String }
        do {
            let _: Empty = try await APIClient.shared.post(
                "/api/push/register",
                body: Body(deviceToken: token, platform: "ios", userId: userId)
            )
        } catch {
            print("Failed to register device token: \(error)")
        }
    }

    func unregisterDevice() async {
        do {
            try await APIClient.shared.deleteVoid("/api/push/register")
        } catch {
            print("Failed to unregister device: \(error)")
        }
    }

    func fetchPreferences() async throws -> NotificationPreferences {
        try await APIClient.shared.get("/api/push/preferences")
    }

    func updatePreferences(_ prefs: NotificationPreferences) async throws {
        let _: Empty = try await APIClient.shared.put("/api/push/preferences", body: prefs)
    }
}

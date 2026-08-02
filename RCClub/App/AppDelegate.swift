import UIKit
import UserNotifications

@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    weak var appState: AppState?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        PushNotificationService.shared.didReceiveDeviceToken(tokenString, userId: appState?.currentUser?.id)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
    }

    /// Show banners even while the app is in the foreground.
    ///
    /// `UNUserNotificationCenterDelegate` requirements are `nonisolated` and carry
    /// non-`Sendable` parameter types, so these can't be `@MainActor`-isolated like
    /// the rest of the class — they hop over explicitly wherever they touch `appState`.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    /// User tapped a notification — route to the relevant screen.
    ///
    /// `userInfo` is `[AnyHashable: Any]`, which can never be `Sendable`. Flatten it to
    /// a plain `[String: String]` here — while still nonisolated — before crossing over
    /// to the main-actor-isolated `AppState`.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let rawUserInfo = response.notification.request.content.userInfo
        var payload: [String: String] = [:]
        for (key, value) in rawUserInfo {
            if let key = key as? String {
                payload[key] = String(describing: value)
            }
        }
        await appState?.handleNotificationTap(userInfo: payload)
    }
}

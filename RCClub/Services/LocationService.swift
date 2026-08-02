import Foundation
import CoreLocation
import UserNotifications

/// Opt-in, battery-efficient proximity detection: watches for significant
/// location changes and prompts a check-in when within ~500m of the field.
@MainActor
final class LocationService: NSObject {
    static let shared = LocationService()

    private let manager = CLLocationManager()
    private var fieldLocation: CLLocation?
    private let proximityRadiusMeters: CLLocationDistance = 500
    private var lastPromptDate: Date?

    private let enabledKey = "rcclub.locationProximityEnabled"

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: enabledKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: enabledKey)
            if newValue { start() } else { stop() }
        }
    }

    private override init() {
        super.init()
        manager.delegate = self
    }

    func configure(fieldLatitude: Double, fieldLongitude: Double) {
        fieldLocation = CLLocation(latitude: fieldLatitude, longitude: fieldLongitude)
        if isEnabled { start() }
    }

    func distanceToField(from location: CLLocation) -> CLLocationDistance? {
        fieldLocation.map { location.distance(from: $0) }
    }

    private func start() {
        guard fieldLocation != nil else { return }
        manager.requestAlwaysAuthorization()
        manager.startMonitoringSignificantLocationChanges()
    }

    private func stop() {
        manager.stopMonitoringSignificantLocationChanges()
    }

    private func evaluateProximity(to location: CLLocation) {
        guard isEnabled, let fieldLocation else { return }
        guard location.distance(from: fieldLocation) <= proximityRadiusMeters else { return }
        if let last = lastPromptDate, Date().timeIntervalSince(last) < 3600 { return }
        lastPromptDate = Date()
        promptCheckIn()
    }

    private func promptCheckIn() {
        let content = UNMutableNotificationContent()
        content.title = "You're near the field"
        content.body = "Looks like you're at the field — check in?"
        content.userInfo = ["type": "fieldStatus"]
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "field-proximity-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.evaluateProximity(to: location)
        }
    }
}

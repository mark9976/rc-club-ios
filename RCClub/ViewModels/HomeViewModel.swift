import Foundation
import Observation

@Observable
@MainActor
final class HomeViewModel {
    var fieldStatus: FieldStatus?
    var weather: WeatherData?
    var forecastDays: [ForecastDay] = []
    var nextEvent: Event?
    var recentPhotos: [Photo] = []
    var isLoading = false
    var isTogglingCheckIn = false
    var errorMessage: String?

    private struct CheckInBody: Encodable { let userId: String }

    func loadAll() async {
        isLoading = true
        errorMessage = nil

        async let statusResult = Self.fetchResult { try await APIClient.shared.get("/api/field-status") as FieldStatus }
        async let forecastTask: WeatherData.Forecast? = try? APIClient.shared.get("/api/forecast")
        async let eventsTask: [Event]? = try? APIClient.shared.get("/api/events")
        async let photosTask: [Photo]? = try? APIClient.shared.get("/api/photos/recent")

        switch await statusResult {
        case .success(let status):
            fieldStatus = status
        case .failure(let error):
            fieldStatus = nil
            errorMessage = error.localizedDescription
        }
        if let forecast = await forecastTask {
            weather = forecast.current
            forecastDays = forecast.days
        }
        nextEvent = await eventsTask?.first
        recentPhotos = await photosTask ?? []
        isLoading = false
    }

    private static func fetchResult<T>(_ operation: @Sendable () async throws -> T) async -> Result<T, Error> {
        do {
            return .success(try await operation())
        } catch {
            return .failure(error)
        }
    }

    func refreshFieldStatus() async {
        fieldStatus = try? await APIClient.shared.get("/api/field-status")
    }

    func toggleCheckIn(userId: String, appState: AppState) async {
        isTogglingCheckIn = true
        do {
            if appState.isCheckedIn {
                let _: Empty = try await APIClient.shared.delete("/api/checkin", body: CheckInBody(userId: userId))
                appState.isCheckedIn = false
            } else {
                let _: Empty = try await APIClient.shared.post("/api/checkin", body: CheckInBody(userId: userId))
                appState.isCheckedIn = true
            }
            Haptics.success()
            await refreshFieldStatus()
        } catch {
            Haptics.warning()
            errorMessage = error.localizedDescription
        }
        isTogglingCheckIn = false
    }
}

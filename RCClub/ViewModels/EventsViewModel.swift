import Foundation
import Observation

@Observable
@MainActor
final class EventsViewModel {
    var events: [Event] = []
    var isLoading = false
    var errorMessage: String?

    private struct EventBody: Encodable {
        let title: String
        let date: String
        let time: String?
        let location: String?
        let description: String?
    }

    private struct EventsResponse: Decodable { let events: [Event] }

    var sortedEvents: [Event] {
        events.sorted { ($0.date.asDate ?? .distantFuture) < ($1.date.asDate ?? .distantFuture) }
    }

    func loadEvents() async {
        isLoading = true
        errorMessage = nil
        do {
            let response: EventsResponse = try await APIClient.shared.get("/api/events")
            events = response.events
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func createEvent(title: String, date: String, time: String?, location: String?, description: String?) async {
        do {
            let event: Event = try await APIClient.shared.post(
                "/api/events",
                body: EventBody(title: title, date: date, time: time, location: location, description: description)
            )
            events.append(event)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateEvent(_ id: String, title: String, date: String, time: String?, location: String?, description: String?) async {
        do {
            let event: Event = try await APIClient.shared.put(
                "/api/events/\(id)",
                body: EventBody(title: title, date: date, time: time, location: location, description: description)
            )
            if let index = events.firstIndex(where: { $0.id == id }) {
                events[index] = event
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteEvent(_ id: String) async {
        do {
            try await APIClient.shared.deleteVoid("/api/events/\(id)")
            events.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

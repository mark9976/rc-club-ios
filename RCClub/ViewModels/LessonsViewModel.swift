import Foundation
import Observation

@Observable
@MainActor
final class LessonsViewModel {
    var myRequests: [LessonRequest] = []        // student view
    var incomingRequests: [LessonRequest] = []  // instructor view: open requests
    var myStudents: [LessonRequest] = []        // instructor view: accepted/scheduled/completed
    var isLoading = false
    var isSubmitting = false
    var errorMessage: String?

    private struct RequestBody: Encodable {
        let type: String
        let experienceLevel: String
        let preferredTimes: String?
        let notes: String?
    }
    private struct ScheduleBody: Encodable { let scheduledDate: String }

    func load(for user: User) async {
        isLoading = true
        errorMessage = nil
        do {
            let requests: [LessonRequest] = try await APIClient.shared.get("/api/lessons")
            if user.isInstructor {
                incomingRequests = requests.filter { $0.status == LessonStatus.pending.rawValue }
                myStudents = requests.filter { $0.instructorId == user.id && $0.status != LessonStatus.pending.rawValue }
            } else {
                myRequests = requests
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func submitRequest(types: [LessonType], experience: ExperienceLevel, preferredTimes: String, notes: String) async -> Bool {
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            let typeLabel = types.map(\.rawValue).joined(separator: ",")
            let request: LessonRequest = try await APIClient.shared.post(
                "/api/lessons",
                body: RequestBody(
                    type: typeLabel,
                    experienceLevel: experience.rawValue,
                    preferredTimes: preferredTimes.isEmpty ? nil : preferredTimes,
                    notes: notes.isEmpty ? nil : notes
                )
            )
            myRequests.insert(request, at: 0)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func accept(_ id: Int) async {
        do {
            let updated: LessonRequest = try await APIClient.shared.put("/api/lessons/\(id)/accept", body: Empty())
            incomingRequests.removeAll { $0.id == id }
            myStudents.insert(updated, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Leaves the request open for other instructors — no server call needed.
    func pass(_ id: Int) {
        incomingRequests.removeAll { $0.id == id }
    }

    func schedule(_ id: Int, date: String) async {
        do {
            let updated: LessonRequest = try await APIClient.shared.put(
                "/api/lessons/\(id)/schedule",
                body: ScheduleBody(scheduledDate: date)
            )
            replace(updated)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markComplete(_ id: Int) async {
        do {
            let updated: LessonRequest = try await APIClient.shared.put("/api/lessons/\(id)/complete", body: Empty())
            replace(updated)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func replace(_ updated: LessonRequest) {
        if let index = myStudents.firstIndex(where: { $0.id == updated.id }) {
            myStudents[index] = updated
        }
        if let index = myRequests.firstIndex(where: { $0.id == updated.id }) {
            myRequests[index] = updated
        }
    }
}

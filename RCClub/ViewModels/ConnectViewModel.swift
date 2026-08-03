import Foundation
import Observation

@Observable
@MainActor
final class ConnectViewModel {
    var communityCount: Int = 0
    var groups: [RCGroup] = []
    var isLoading = false
    var errorMessage: String?
    var newGroupName = ""
    var isCreatingGroup = false

    private struct CheckInBody: Encodable { let userId: String }
    private struct CreateGroupBody: Encodable { let name: String }
    private struct GroupsListResponse: Decodable { let groups: [RCGroup] }
    private struct GroupResponse: Decodable { let group: RCGroup }

    func loadAll() async {
        isLoading = true
        errorMessage = nil
        // There's no standalone /api/checkin/count endpoint — the live count
        // comes back as part of /api/field-status instead.
        async let statusTask: FieldStatus? = try? APIClient.shared.get("/api/field-status")
        async let groupsTask: GroupsListResponse? = try? APIClient.shared.get("/api/connect-groups/")
        communityCount = await statusTask?.checkedInCount ?? 0
        groups = await groupsTask?.groups ?? []
        isLoading = false
    }

    func refreshCommunityCount() async {
        if let status: FieldStatus = try? await APIClient.shared.get("/api/field-status") {
            communityCount = status.checkedInCount
        }
    }

    func toggleCheckIn(userId: String, appState: AppState) async {
        do {
            if appState.isCheckedIn {
                let _: Empty = try await APIClient.shared.delete("/api/checkin", body: CheckInBody(userId: userId))
                appState.isCheckedIn = false
            } else {
                let _: Empty = try await APIClient.shared.post("/api/checkin", body: CheckInBody(userId: userId))
                appState.isCheckedIn = true
            }
            Haptics.success()
            await refreshCommunityCount()
        } catch {
            Haptics.warning()
            errorMessage = error.localizedDescription
        }
    }

    func createGroup() async -> RCGroup? {
        guard !newGroupName.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        isCreatingGroup = true
        defer { isCreatingGroup = false }
        do {
            let response: GroupResponse = try await APIClient.shared.post(
                "/api/connect-groups/",
                body: CreateGroupBody(name: newGroupName)
            )
            groups.append(response.group)
            newGroupName = ""
            return response.group
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}

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

    func loadAll() async {
        isLoading = true
        errorMessage = nil
        async let countTask: CheckInCount? = try? APIClient.shared.get("/api/checkin/count")
        async let groupsTask: [RCGroup]? = try? APIClient.shared.get("/api/groups")
        communityCount = await countTask?.count ?? 0
        groups = await groupsTask ?? []
        isLoading = false
    }

    func refreshCommunityCount() async {
        if let count: CheckInCount = try? await APIClient.shared.get("/api/checkin/count") {
            communityCount = count.count
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
            let group: RCGroup = try await APIClient.shared.post(
                "/api/groups",
                body: CreateGroupBody(name: newGroupName)
            )
            groups.append(group)
            newGroupName = ""
            return group
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}

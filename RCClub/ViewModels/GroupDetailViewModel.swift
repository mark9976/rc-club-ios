import Foundation
import Observation

@Observable
@MainActor
final class GroupDetailViewModel {
    var group: RCGroup
    var members: [GroupMember] = []
    var messages: [GroupMessage] = []
    var messageText = ""
    var isLoading = false
    var isSending = false
    var errorMessage: String?

    var checkedInMembers: [GroupMember] { members.filter(\.isCheckedIn) }

    private struct SendMessageBody: Encodable { let text: String }
    private struct BroadcastBody: Encodable { let text: String }
    private struct AddMemberBody: Encodable { let userId: Int }
    private struct RenameBody: Encodable { let name: String }

    init(group: RCGroup) {
        self.group = group
    }

    func loadAll() async {
        isLoading = true
        errorMessage = nil
        async let membersTask: [GroupMember]? = try? APIClient.shared.get("/api/groups/\(group.id)/members")
        async let messagesTask: [GroupMessage]? = try? APIClient.shared.get(
            "/api/groups/\(group.id)/messages",
            query: ["page": "1", "limit": "50"]
        )
        members = await membersTask ?? []
        messages = (await messagesTask ?? []).sorted {
            ($0.sentAt.asDate ?? .distantPast) < ($1.sentAt.asDate ?? .distantPast)
        }
        isLoading = false
    }

    func sendMessage() async {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messageText = ""
        isSending = true
        do {
            let message: GroupMessage = try await APIClient.shared.post(
                "/api/groups/\(group.id)/messages",
                body: SendMessageBody(text: text)
            )
            messages.append(message)
        } catch {
            errorMessage = error.localizedDescription
        }
        isSending = false
    }

    func sendBroadcast(_ broadcast: QuickBroadcast) async {
        do {
            let _: Empty = try await APIClient.shared.post(
                "/api/groups/\(group.id)/broadcast",
                body: BroadcastBody(text: broadcast.rawValue)
            )
            await loadAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addMember(userId: Int) async {
        do {
            let member: GroupMember = try await APIClient.shared.post(
                "/api/groups/\(group.id)/members",
                body: AddMemberBody(userId: userId)
            )
            members.append(member)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeMember(userId: Int) async {
        do {
            try await APIClient.shared.deleteVoid("/api/groups/\(group.id)/members/\(userId)")
            members.removeAll { $0.userId == userId }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rename(to name: String) async {
        do {
            let updated: RCGroup = try await APIClient.shared.put(
                "/api/groups/\(group.id)",
                body: RenameBody(name: name)
            )
            group = updated
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteGroup() async -> Bool {
        do {
            try await APIClient.shared.deleteVoid("/api/groups/\(group.id)")
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func leaveGroup(currentUserId: Int) async -> Bool {
        await removeMember(userId: currentUserId)
        return errorMessage == nil
    }
}

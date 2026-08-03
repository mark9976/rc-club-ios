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

    private struct SendMessageBody: Encodable { let text: String; let isBroadcast: Bool }
    private struct AddMemberBody: Encodable { let userId: String }
    private struct RenameBody: Encodable { let name: String }

    private struct MembersResponse: Decodable { let members: [GroupMember] }
    private struct MessagesResponse: Decodable { let messages: [GroupMessage] }
    private struct MessageResponse: Decodable { let message: GroupMessage }
    private struct GroupResponse: Decodable { let group: RCGroup }

    private var basePath: String { "/api/connect-groups/\(group.id)" }

    init(group: RCGroup) {
        self.group = group
    }

    func loadAll() async {
        isLoading = true
        errorMessage = nil
        async let membersTask: MembersResponse? = try? APIClient.shared.get("\(basePath)/members/")
        async let messagesTask: MessagesResponse? = try? APIClient.shared.get(
            "\(basePath)/messages/",
            query: ["page": "1", "limit": "50"]
        )
        members = await membersTask?.members ?? []
        messages = (await messagesTask?.messages ?? []).sorted {
            ($0.sentAt.asDate ?? .distantPast) < ($1.sentAt.asDate ?? .distantPast)
        }
        isLoading = false
    }

    func sendMessage() async {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messageText = ""
        await send(text: text, isBroadcast: false)
    }

    func sendBroadcast(_ broadcast: QuickBroadcast) async {
        await send(text: broadcast.rawValue, isBroadcast: true)
    }

    private func send(text: String, isBroadcast: Bool) async {
        isSending = true
        do {
            let response: MessageResponse = try await APIClient.shared.post(
                "\(basePath)/messages/",
                body: SendMessageBody(text: text, isBroadcast: isBroadcast)
            )
            messages.append(response.message)
        } catch {
            errorMessage = error.localizedDescription
        }
        isSending = false
    }

    func addMember(userId: String) async {
        do {
            let response: MembersResponse = try await APIClient.shared.post(
                "\(basePath)/members/",
                body: AddMemberBody(userId: userId)
            )
            members = response.members
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeMember(userId: String) async {
        do {
            try await APIClient.shared.deleteVoid("\(basePath)/members/\(userId)/")
            members.removeAll { $0.userId == userId }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rename(to name: String) async {
        do {
            let response: GroupResponse = try await APIClient.shared.put(
                "\(basePath)/",
                body: RenameBody(name: name)
            )
            group = response.group
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteGroup() async -> Bool {
        do {
            try await APIClient.shared.deleteVoid("\(basePath)/")
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func leaveGroup(currentUserId: String) async -> Bool {
        await removeMember(userId: currentUserId)
        return errorMessage == nil
    }
}

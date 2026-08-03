import SwiftUI

struct MemberPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    let onSelect: (User) -> Void

    @State private var searchText = ""
    @State private var roster: [User] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private struct MembersResponse: Decodable { let members: [User] }

    private var filteredRoster: [User] {
        let others = roster.filter { $0.id != appState.currentUser?.id }
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return others }
        return others.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredRoster) { user in
                Button {
                    onSelect(user)
                    dismiss()
                } label: {
                    VStack(alignment: .leading) {
                        Text(user.name).foregroundStyle(.primary)
                        if !user.email.isEmpty {
                            Text(user.email).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                } else if let errorMessage {
                    EmptyStateView(icon: "wifi.slash", title: "Couldn't load members", message: errorMessage)
                } else if filteredRoster.isEmpty {
                    EmptyStateView(icon: "person.crop.circle.badge.questionmark", title: "No members found")
                }
            }
            .searchable(text: $searchText, prompt: "Search members")
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task { await loadRoster() }
        }
    }

    private func loadRoster() async {
        isLoading = true
        errorMessage = nil
        do {
            let response: MembersResponse = try await APIClient.shared.get("/api/members")
            roster = response.members
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

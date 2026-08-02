import SwiftUI

struct MemberPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (User) -> Void

    @State private var searchText = ""
    @State private var results: [User] = []
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            List(results) { user in
                Button {
                    onSelect(user)
                    dismiss()
                } label: {
                    VStack(alignment: .leading) {
                        Text(user.name).foregroundStyle(.primary)
                        Text(user.email).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .overlay {
                if isSearching {
                    ProgressView()
                } else if results.isEmpty && !searchText.isEmpty {
                    EmptyStateView(icon: "person.crop.circle.badge.questionmark", title: "No members found")
                }
            }
            .searchable(text: $searchText, prompt: "Search members")
            .onChange(of: searchText) { _, newValue in
                Task { await search(newValue) }
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func search(_ query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }
        isSearching = true
        results = (try? await APIClient.shared.get("/api/members", query: ["search": query])) ?? []
        isSearching = false
    }
}

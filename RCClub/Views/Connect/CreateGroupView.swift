import SwiftUI

struct CreateGroupView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: ConnectViewModel

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            Form {
                Section("Group Name") {
                    TextField("e.g. Saturday Flyers", text: $viewModel.newGroupName)
                }
                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(Color.dangerRed)
                }
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            if await viewModel.createGroup() != nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(
                        viewModel.isCreatingGroup
                            || viewModel.newGroupName.trimmingCharacters(in: .whitespaces).isEmpty
                    )
                }
            }
        }
    }
}

import SwiftUI

struct ManageGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: GroupDetailViewModel
    @State private var newName = ""
    @State private var showMemberPicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Group Name") {
                    HStack {
                        TextField("Group name", text: $newName)
                        Button("Save") {
                            Task { await viewModel.rename(to: newName) }
                        }
                        .disabled(
                            newName.trimmingCharacters(in: .whitespaces).isEmpty
                                || newName == viewModel.group.name
                        )
                    }
                }

                Section("Members") {
                    ForEach(viewModel.members) { member in
                        HStack {
                            Text(member.name)
                            Spacer()
                            if member.isCheckedIn {
                                Text("At field")
                                    .font(.caption)
                                    .foregroundStyle(Color.successGreen)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let member = viewModel.members[index]
                            Task { await viewModel.removeMember(userId: member.userId) }
                        }
                    }

                    Button {
                        showMemberPicker = true
                    } label: {
                        Label("Add Member", systemImage: "person.badge.plus")
                    }
                }

                Section {
                    Button("Delete Group", role: .destructive) {
                        Task {
                            if await viewModel.deleteGroup() {
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear { newName = viewModel.group.name }
            .sheet(isPresented: $showMemberPicker) {
                MemberPickerView { user in
                    Task { await viewModel.addMember(userId: user.id) }
                }
            }
        }
    }
}

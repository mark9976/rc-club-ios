import SwiftUI

struct GroupDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: GroupDetailViewModel
    @State private var showManage = false

    init(group: RCGroup) {
        _viewModel = State(initialValue: GroupDetailViewModel(group: group))
    }

    private var isCreator: Bool {
        appState.currentUser?.id == viewModel.group.createdBy
    }

    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.checkedInMembers.isEmpty {
                checkedInStrip
            }
            GroupChatView(viewModel: viewModel)
        }
        .background(Color.screenBackground)
        .navigationTitle(viewModel.group.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if isCreator {
                        Button("Manage Group") { showManage = true }
                    } else {
                        Button("Leave Group", role: .destructive) {
                            Task {
                                guard let uid = appState.currentUser?.id else { return }
                                if await viewModel.leaveGroup(currentUserId: uid) {
                                    dismiss()
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task { await viewModel.loadAll() }
        .sheet(isPresented: $showManage) {
            ManageGroupView(viewModel: viewModel)
        }
    }

    private var checkedInStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.checkedInMembers) { member in
                    Label(member.name, systemImage: "mappin.circle.fill")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.successGreen.opacity(0.12), in: Capsule())
                        .foregroundStyle(Color.successGreen)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

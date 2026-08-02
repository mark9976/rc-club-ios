import SwiftUI

struct ConnectView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ConnectViewModel()
    @State private var showCreateGroup = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    CommunityStatusView(
                        count: viewModel.communityCount,
                        isCheckedIn: appState.isCheckedIn
                    ) {
                        Task {
                            guard let userId = appState.currentUser?.id else { return }
                            await viewModel.toggleCheckIn(userId: userId, appState: appState)
                        }
                    }

                    GroupListView(groups: viewModel.groups, isLoading: viewModel.isLoading)
                }
                .padding()
            }
            .background(Color.screenBackground)
            .navigationTitle("Connect")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateGroup = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .refreshable { await viewModel.loadAll() }
            .navigationDestination(for: RCGroup.self) { group in
                GroupDetailView(group: group)
            }
            .sheet(isPresented: $showCreateGroup) {
                CreateGroupView(viewModel: viewModel)
            }
        }
        .task { await viewModel.loadAll() }
    }
}

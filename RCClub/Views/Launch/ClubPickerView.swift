import SwiftUI

struct ClubPickerView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ClubPickerViewModel()
    @State private var manualCode = ""
    @State private var showClubInquiry = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.clubs.isEmpty {
                    LoadingView(message: "Loading clubs…")
                } else if let error = viewModel.errorMessage, viewModel.clubs.isEmpty {
                    EmptyStateView(
                        icon: "wifi.slash",
                        title: "Couldn't load clubs",
                        message: error,
                        actionTitle: "Try Again"
                    ) {
                        Task { await viewModel.loadClubs() }
                    }
                } else {
                    List {
                        Section {
                            HStack {
                                TextField("Enter club code", text: $manualCode)
                                    .textInputAutocapitalization(.characters)
                                    .autocorrectionDisabled()
                                Button("Go") { selectByCode() }
                                    .disabled(manualCode.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                        } header: {
                            Text("Have a club code?")
                        }

                        Section {
                            ForEach(viewModel.filteredClubs) { club in
                                Button {
                                    appState.addAndSelectClub(club)
                                } label: {
                                    HStack(spacing: 12) {
                                        clubLogo(club)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(club.name)
                                                .font(.body.weight(.medium))
                                                .foregroundStyle(.primary)
                                            Text(club.id)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        } header: {
                            Text("Clubs")
                        } footer: {
                            Button("Don't see your club? Learn more") {
                                showClubInquiry = true
                            }
                            .font(.footnote)
                        }
                    }
                    .searchable(text: $viewModel.searchText, prompt: "Search clubs")
                    .refreshable { await viewModel.loadClubs() }
                }
            }
            .navigationTitle("Select Your Club")
        }
        .task {
            if viewModel.clubs.isEmpty {
                await viewModel.loadClubs()
            }
        }
        .sheet(isPresented: $showClubInquiry) {
            ClubInquiryInfoView()
        }
    }

    private func selectByCode() {
        let code = manualCode.trimmingCharacters(in: .whitespaces)
        guard let club = ClubRegistry.shared.findClub(byCode: code, in: viewModel.clubs) else { return }
        appState.addAndSelectClub(club)
    }

    @ViewBuilder
    private func clubLogo(_ club: Club) -> some View {
        if let logo = club.logo, let url = URL(string: logo) {
            AsyncImageLoader(url: url, contentMode: .fit, cornerRadius: 8)
                .frame(width: 40, height: 40)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentTeal.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "airplane")
                        .foregroundStyle(Color.accentTeal)
                }
        }
    }
}

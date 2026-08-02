import SwiftUI
import UIKit

struct ClubInfoView: View {
    @Environment(AppState.self) private var appState
    var viewModel: ProfileViewModel

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    if let logo = appState.activeClub?.logo, let url = URL(string: logo) {
                        AsyncImageLoader(url: url, contentMode: .fit, cornerRadius: 12)
                            .frame(width: 56, height: 56)
                    }
                    Text(appState.activeClub?.name ?? viewModel.clubConfig?.name ?? "")
                        .font(.headline)
                }
            }

            if let address = viewModel.clubConfig?.fieldAddress {
                Section("Field") {
                    Text(address)
                    Button("Get Directions") {
                        openDirections(address: address)
                    }
                }
            }

            if let website = viewModel.clubConfig?.website, let url = URL(string: website) {
                Section {
                    Link("Club Website", destination: url)
                }
            }

            Section("Clubs") {
                ForEach(appState.savedClubs) { club in
                    Button {
                        appState.switchClub(club)
                    } label: {
                        HStack {
                            Text(club.name)
                            Spacer()
                            if club.id == appState.activeClub?.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
                Button("Add Another Club") {
                    appState.activeClub = nil
                }
            }
        }
        .navigationTitle("Club Info")
    }

    private func openDirections(address: String) {
        guard let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://maps.apple.com/?daddr=\(encoded)") else { return }
        UIApplication.shared.open(url)
    }
}

import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        if let logo = appState.activeClub?.logo, let url = URL(string: logo) {
                            AsyncImageLoader(url: url, contentMode: .fit, cornerRadius: 16)
                                .frame(width: 88, height: 88)
                        } else {
                            Image(systemName: "airplane.circle.fill")
                                .font(.system(size: 72))
                                .foregroundStyle(Color.accentTeal)
                        }
                        Text(appState.activeClub?.name ?? "")
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)

                    VStack(spacing: 16) {
                        TextField("Username", text: $viewModel.username)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 12))

                        SecureField("Password", text: $viewModel.password)
                            .textContentType(.password)
                            .padding()
                            .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 12))

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(Color.dangerRed)
                        }

                        Button {
                            Task {
                                guard let club = appState.activeClub else { return }
                                await viewModel.login(club: club, appState: appState)
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Sign In").frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.accentTeal)
                        .controlSize(.large)
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal)

                    Button("Not your club? Switch") {
                        appState.activeClub = nil
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            .background(Color.screenBackground)
            .navigationBarHidden(true)
        }
    }
}

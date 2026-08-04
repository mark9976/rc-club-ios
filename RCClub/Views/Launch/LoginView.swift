import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = AuthViewModel()
    @State private var didAutoPromptBiometrics = false

    private var biometryKind: BiometricAuthService.Kind { BiometricAuthService.availableKind }
    private var showBiometricSignIn: Bool {
        appState.hasStoredSessionPendingBiometric && biometryKind != .none
    }

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

                    if showBiometricSignIn {
                        VStack(spacing: 12) {
                            Button {
                                Task { await viewModel.signInWithBiometrics(appState: appState) }
                            } label: {
                                if viewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Label("Sign In with \(biometryKind.label)", systemImage: biometryKind.systemImage)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.accentTeal)
                            .controlSize(.large)
                            .disabled(viewModel.isLoading)

                            HStack {
                                Rectangle().frame(height: 1).foregroundStyle(.separator)
                                Text("or sign in manually").font(.caption).foregroundStyle(.secondary)
                                Rectangle().frame(height: 1).foregroundStyle(.separator)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal)
                    }

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
        .task {
            guard showBiometricSignIn, !didAutoPromptBiometrics else { return }
            didAutoPromptBiometrics = true
            await viewModel.signInWithBiometrics(appState: appState)
        }
    }
}

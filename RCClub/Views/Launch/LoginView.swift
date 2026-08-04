import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = AuthViewModel()
    @State private var didAutoPromptBiometrics = false
    @State private var showManualFallback = false
    @AppStorage("rcclub.biometricLoginEnabled") private var biometricLoginEnabled = false

    private var biometryKind: BiometricAuthService.Kind { BiometricAuthService.availableKind }

    /// True once a stored session exists and biometric login was previously
    /// opted into — the whole point being no username/password fields at all.
    private var showBiometricOnlyScreen: Bool {
        appState.hasStoredSessionPendingBiometric && biometryKind != .none && !showManualFallback
    }

    /// True right after a successful manual login, on a device that has
    /// biometrics but hasn't opted in yet — this drives the "enable?" prompt.
    private var awaitingBiometricOptIn: Bool {
        viewModel.pendingUser != nil && biometryKind != .none && !biometricLoginEnabled
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header

                    if showBiometricOnlyScreen {
                        biometricOnlySection
                    } else {
                        manualLoginSection
                    }

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
            guard showBiometricOnlyScreen, !didAutoPromptBiometrics else { return }
            didAutoPromptBiometrics = true
            await viewModel.signInWithBiometrics(appState: appState)
        }
        .alert(
            "Enable \(biometryKind.label)?",
            isPresented: Binding(get: { awaitingBiometricOptIn }, set: { if !$0 { completePendingLogin() } })
        ) {
            Button("Enable") {
                biometricLoginEnabled = true
                completePendingLogin()
            }
            Button("Not Now", role: .cancel) {
                completePendingLogin()
            }
        } message: {
            Text("Use \(biometryKind.label) to sign in instantly next time, without typing your password.")
        }
    }

    private var header: some View {
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
    }

    @ViewBuilder
    private var biometricOnlySection: some View {
        VStack(spacing: 16) {
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

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Color.dangerRed)
            }

            Button("Use Password Instead") {
                showManualFallback = true
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var manualLoginSection: some View {
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
                    await viewModel.login(club: club)
                    guard viewModel.pendingUser != nil else { return }
                    // No biometry on this device, or already opted in — nothing to
                    // ask, complete right away. Otherwise the alert's binding takes over.
                    if biometryKind == .none || biometricLoginEnabled {
                        completePendingLogin()
                    }
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
    }

    private func completePendingLogin() {
        guard let user = viewModel.pendingUser else { return }
        viewModel.pendingUser = nil
        appState.completeLogin(user: user)
    }
}

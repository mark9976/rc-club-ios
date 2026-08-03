import SwiftUI

struct BiometricLockView: View {
    let kind: BiometricAuthService.Kind
    let onUnlock: () -> Void

    @State private var isAuthenticating = false
    @State private var failed = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: kind.systemImage)
                .font(.system(size: 64))
                .foregroundStyle(Color.accentTeal)
            Text("RC Club Locked")
                .font(.title2.bold())
            if failed {
                Text("Authentication failed. Try again.")
                    .font(.footnote)
                    .foregroundStyle(Color.dangerRed)
            }
            Button {
                Task { await unlock() }
            } label: {
                Label("Unlock with \(kind.label)", systemImage: kind.systemImage)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.accentTeal)
            .controlSize(.large)
            .padding(.horizontal, 40)
            .disabled(isAuthenticating)
            Spacer()
        }
        .background(Color.screenBackground)
        .task { await unlock() }
    }

    private func unlock() async {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        let success = await BiometricAuthService.authenticate(reason: "Unlock RC Club")
        isAuthenticating = false
        if success {
            onUnlock()
        } else {
            failed = true
        }
    }
}

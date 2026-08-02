import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ProfileViewModel()
    @State private var showChangePassword = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        if let photo = appState.currentUser?.profilePhoto, let url = URL(string: photo) {
                            AsyncImageLoader(url: url, contentMode: .fill, cornerRadius: 32)
                                .frame(width: 64, height: 64)
                        } else {
                            Circle()
                                .fill(Color.accentTeal.opacity(0.15))
                                .frame(width: 64, height: 64)
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .font(.title2)
                                        .foregroundStyle(Color.accentTeal)
                                }
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appState.currentUser?.name ?? "")
                                .font(.headline)
                            Text(appState.currentUser?.email ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let since = appState.currentUser?.memberSince {
                                Text("Member since \(since)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            if let ama = appState.currentUser?.amaNumber {
                                Text("AMA #\(ama)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    NavigationLink {
                        ClubInfoView(viewModel: viewModel)
                    } label: {
                        Label("Club Info", systemImage: "building.2")
                    }
                    NavigationLink {
                        NotificationSettingsView(viewModel: viewModel)
                    } label: {
                        Label("Notification Settings", systemImage: "bell.badge")
                    }
                    NavigationLink {
                        AppSettingsView()
                    } label: {
                        Label("App Settings", systemImage: "gearshape")
                    }
                }

                Section("Account") {
                    Button("Change Password") { showChangePassword = true }
                    Button("Logout", role: .destructive) {
                        appState.logout()
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView(viewModel: viewModel)
            }
        }
        .task { await viewModel.loadAll() }
    }
}

private struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: ProfileViewModel

    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isSaving = false

    private var canSubmit: Bool {
        !oldPassword.isEmpty && !newPassword.isEmpty && newPassword == confirmPassword
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Current Password", text: $oldPassword)
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm New Password", text: $confirmPassword)
                }
                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(Color.dangerRed)
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            isSaving = true
                            let success = await viewModel.changePassword(
                                oldPassword: oldPassword,
                                newPassword: newPassword
                            )
                            isSaving = false
                            if success { dismiss() }
                        }
                    }
                    .disabled(!canSubmit || isSaving)
                }
            }
        }
    }
}

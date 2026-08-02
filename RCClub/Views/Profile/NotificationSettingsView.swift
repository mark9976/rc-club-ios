import SwiftUI

struct NotificationSettingsView: View {
    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Field Status Changes", isOn: $viewModel.notificationPreferences.fieldStatus)
                Toggle("Events", isOn: $viewModel.notificationPreferences.events)
                Toggle("Instruction Requests/Updates", isOn: $viewModel.notificationPreferences.lessons)
                Toggle("Group Broadcasts", isOn: $viewModel.notificationPreferences.groupMessages)
                Toggle("Newsletters", isOn: $viewModel.notificationPreferences.newsletters)
                Toggle("Dues Reminders", isOn: $viewModel.notificationPreferences.duesReminders)
                Toggle("Classifieds", isOn: $viewModel.notificationPreferences.classifieds)
                Toggle("Photos", isOn: $viewModel.notificationPreferences.photos)
            }

            Section("Location") {
                Toggle(
                    "Auto-detect field proximity",
                    isOn: Binding(
                        get: { viewModel.locationEnabled },
                        set: { viewModel.locationEnabled = $0 }
                    )
                )
                Text("When enabled, the app can prompt you to check in when you're near the field, even if it isn't open.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Notifications")
        .onChange(of: viewModel.notificationPreferences) { _, _ in
            Task { await viewModel.savePreferences() }
        }
    }
}

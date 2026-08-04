import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

struct AppSettingsView: View {
    @AppStorage("rcclub.appTheme") private var themeRaw = AppTheme.system.rawValue
    @AppStorage("rcclub.biometricLoginEnabled") private var biometricLoginEnabled = false

    private var theme: Binding<AppTheme> {
        Binding(
            get: { AppTheme(rawValue: themeRaw) ?? .system },
            set: { themeRaw = $0.rawValue }
        )
    }

    private var biometryKind: BiometricAuthService.Kind { BiometricAuthService.availableKind }

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: theme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.label).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }

            if biometryKind != .none {
                Section {
                    Toggle("Sign in with \(biometryKind.label)", isOn: $biometricLoginEnabled)
                } header: {
                    Text("Security")
                } footer: {
                    Text("When on, opening the app skips your password and unlocks with \(biometryKind.label) instead.")
                }
            }

            Section("About") {
                LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                LabeledContent("Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
            }
        }
        .navigationTitle("App Settings")
    }
}

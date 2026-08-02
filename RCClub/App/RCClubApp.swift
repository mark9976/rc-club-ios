import SwiftUI

@main
struct RCClubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .task {
                    appDelegate.appState = appState
                }
        }
    }
}

/// Top-level router: club selection -> login -> main tab experience.
struct RootView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("rcclub.appTheme") private var themeRaw = AppTheme.system.rawValue

    var body: some View {
        Group {
            if appState.activeClub == nil {
                ClubPickerView()
            } else if !appState.isAuthenticated {
                LoginView()
            } else {
                ContentView()
            }
        }
        .animation(.default, value: appState.isAuthenticated)
        .animation(.default, value: appState.activeClub?.id)
        .preferredColorScheme((AppTheme(rawValue: themeRaw) ?? .system).colorScheme)
    }
}

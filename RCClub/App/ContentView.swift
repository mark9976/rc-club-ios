import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(AppTab.home)

            ConnectView()
                .tabItem { Label("Connect", systemImage: "person.2.fill") }
                .tag(AppTab.connect)

            ExploreView()
                .tabItem { Label("Explore", systemImage: "safari.fill") }
                .tag(AppTab.explore)

            LessonsView()
                .tabItem { Label("Lessons", systemImage: "graduationcap.fill") }
                .tag(AppTab.lessons)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(AppTab.profile)
        }
        .tint(Color.accentTeal)
        .task {
            await PushNotificationService.shared.requestAuthorizationIfNeeded()
        }
    }
}

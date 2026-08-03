import Foundation
import Observation

enum AppTab: Hashable {
    case home, connect, explore, lessons, profile
}

enum DeepLink: Equatable {
    case event(Int)
    case group(Int)
    case lesson(Int)
    case classified(Int)
    case fieldStatus
}

/// Single source of truth for which club is active, who's signed in, and
/// where the app should navigate to in response to a tapped notification.
@Observable
@MainActor
final class AppState {
    // MARK: - TESTING ONLY — login bypass
    //
    // Was needed while the server was only reachable over plain HTTP without
    // a working login flow. Now that lhmac.info is live on HTTPS with real
    // login working, this is off — flip back to `true` only for short-term
    // testing, never leave it on for a real release.
    static let bypassLoginForTesting = false
    private static let testUser = User(
        id: 0,
        name: "Test User",
        email: "test@example.com",
        role: "admin",
        profilePhoto: nil,
        memberSince: nil,
        amaNumber: nil
    )

    private(set) var savedClubs: [Club] = []
    var activeClub: Club? {
        didSet { persistActiveClub() }
    }
    var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }
    var selectedTab: AppTab = .home
    var pendingDeepLink: DeepLink?

    /// Local mirror of check-in state, shared by the Home and Connect tabs
    /// so the "I'm at the Field" toggle stays in sync between them.
    var isCheckedIn: Bool = false {
        didSet {
            let state = CheckInLocalState(checkedIn: isCheckedIn, setAt: Date())
            if let data = try? JSONEncoder().encode(state) {
                defaults.set(data, forKey: checkedInKey)
            }
        }
    }

    private let defaults = UserDefaults.standard
    private let savedClubsKey = "rcclub.savedClubs"
    private let activeClubKey = "rcclub.activeClub"
    private let checkedInKey = "rcclub.checkedInState"

    init() {
        loadSavedClubs()
        loadActiveClub()
        loadCheckedInState()
        restoreSessionIfPossible()
        APIClient.shared.onUnauthorized = { [weak self] in self?.currentUser = nil }
    }

    private func loadCheckedInState() {
        guard let data = defaults.data(forKey: checkedInKey),
              let state = try? JSONDecoder().decode(CheckInLocalState.self, from: data),
              !state.isExpired else { return }
        isCheckedIn = state.checkedIn
    }

    func addAndSelectClub(_ club: Club) {
        if !savedClubs.contains(where: { $0.id == club.id }) {
            savedClubs.append(club)
            persistSavedClubs()
        }
        activeClub = club
        currentUser = Self.bypassLoginForTesting ? Self.testUser : nil
    }

    func switchClub(_ club: Club) {
        guard club.id != activeClub?.id else { return }
        currentUser = Self.bypassLoginForTesting ? Self.testUser : nil
        activeClub = club
        if !Self.bypassLoginForTesting {
            restoreSessionIfPossible()
        }
    }

    func completeLogin(user: User) {
        currentUser = user
        PushNotificationService.shared.registerCurrentDeviceIfNeeded(userId: user.id)
    }

    func logout() {
        guard let club = activeClub else { return }
        currentUser = nil
        Task { await AuthService.shared.logout(clubId: club.id) }
    }

    func removeActiveClub() {
        guard let club = activeClub else { return }
        KeychainHelper.shared.deleteToken(forClub: club.id)
        savedClubs.removeAll { $0.id == club.id }
        persistSavedClubs()
        currentUser = nil
        activeClub = savedClubs.first
    }

    func handleNotificationTap(userInfo: [String: String]) {
        guard let type = userInfo["type"] else { return }
        switch type {
        case "event":
            if let id = userInfo["eventId"].flatMap(Int.init) {
                pendingDeepLink = .event(id)
                selectedTab = .explore
            }
        case "group", "groupMessage", "broadcast":
            if let id = userInfo["groupId"].flatMap(Int.init) {
                pendingDeepLink = .group(id)
                selectedTab = .connect
            }
        case "lesson":
            if let id = userInfo["lessonId"].flatMap(Int.init) {
                pendingDeepLink = .lesson(id)
                selectedTab = .lessons
            }
        case "classified":
            if let id = userInfo["classifiedId"].flatMap(Int.init) {
                pendingDeepLink = .classified(id)
                selectedTab = .explore
            }
        case "fieldStatus":
            pendingDeepLink = .fieldStatus
            selectedTab = .home
        default:
            break
        }
    }

    // MARK: - Persistence

    private func restoreSessionIfPossible() {
        if Self.bypassLoginForTesting {
            currentUser = Self.testUser
            return
        }
        guard let club = activeClub,
              let token = KeychainHelper.shared.readToken(forClub: club.id) else { return }
        APIClient.shared.configure(baseURL: club.server, token: token)
        Task {
            if let user = try? await AuthService.shared.validateSession() {
                await MainActor.run { self.currentUser = user }
            }
        }
    }

    private func loadSavedClubs() {
        guard let data = defaults.data(forKey: savedClubsKey),
              let clubs = try? JSONDecoder().decode([Club].self, from: data) else { return }
        savedClubs = clubs
    }

    private func persistSavedClubs() {
        guard let data = try? JSONEncoder().encode(savedClubs) else { return }
        defaults.set(data, forKey: savedClubsKey)
    }

    private func loadActiveClub() {
        guard let data = defaults.data(forKey: activeClubKey),
              let club = try? JSONDecoder().decode(Club.self, from: data) else { return }
        activeClub = club
    }

    private func persistActiveClub() {
        guard let club = activeClub, let data = try? JSONEncoder().encode(club) else {
            defaults.removeObject(forKey: activeClubKey)
            return
        }
        defaults.set(data, forKey: activeClubKey)
        APIClient.shared.configure(baseURL: club.server, token: KeychainHelper.shared.readToken(forClub: club.id))
    }
}

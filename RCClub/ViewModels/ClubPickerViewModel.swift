import Foundation
import Observation

@Observable
@MainActor
final class ClubPickerViewModel {
    var clubs: [Club] = []
    var searchText: String = ""
    var isLoading = false
    var errorMessage: String?

    var filteredClubs: [Club] {
        guard !searchText.isEmpty else { return clubs }
        return clubs.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.id.localizedCaseInsensitiveContains(searchText)
        }
    }

    func loadClubs() async {
        isLoading = true
        errorMessage = nil
        do {
            clubs = try await ClubRegistry.shared.fetchClubs()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

import Foundation
import Observation

@Observable
@MainActor
final class NewsletterViewModel {
    var newsletters: [Newsletter] = []
    var isLoading = false
    var errorMessage: String?

    var sortedNewsletters: [Newsletter] {
        newsletters.sorted { ($0.date.asDate ?? .distantPast) > ($1.date.asDate ?? .distantPast) }
    }

    func loadNewsletters() async {
        isLoading = true
        errorMessage = nil
        do {
            newsletters = try await APIClient.shared.get("/api/newsletters")
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

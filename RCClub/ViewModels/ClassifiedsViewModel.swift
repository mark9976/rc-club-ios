import Foundation
import Observation

@Observable
@MainActor
final class ClassifiedsViewModel {
    var listings: [ClassifiedListing] = []
    var selectedCategory: ClassifiedCategory?
    var isLoading = false
    var isPosting = false
    var errorMessage: String?

    private struct ListingBody: Encodable {
        let title: String
        let price: Double?
        let category: String
        let description: String
    }
    private struct SoldBody: Encodable { let isSold: Bool }

    var filteredListings: [ClassifiedListing] {
        guard let selectedCategory else { return listings }
        return listings.filter { $0.category == selectedCategory.rawValue }
    }

    func loadListings() async {
        isLoading = true
        errorMessage = nil
        do {
            listings = try await APIClient.shared.get("/api/classifieds")
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func postListing(title: String, price: Double?, category: ClassifiedCategory, description: String, photos: [Data]) async -> Bool {
        isPosting = true
        defer { isPosting = false }
        do {
            let listing: ClassifiedListing = try await APIClient.shared.post(
                "/api/classifieds",
                body: ListingBody(title: title, price: price, category: category.rawValue, description: description)
            )
            for (index, photoData) in photos.enumerated() {
                let _: Empty = try await APIClient.shared.upload(
                    "/api/classifieds/\(listing.id)/photos",
                    data: photoData,
                    fieldName: "photo",
                    filename: "listing-\(listing.id)-\(index).jpg",
                    mimeType: "image/jpeg"
                )
            }
            listings.insert(listing, at: 0)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func markSold(_ id: Int) async {
        do {
            let updated: ClassifiedListing = try await APIClient.shared.put(
                "/api/classifieds/\(id)",
                body: SoldBody(isSold: true)
            )
            if let index = listings.firstIndex(where: { $0.id == id }) {
                listings[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteListing(_ id: Int) async {
        do {
            try await APIClient.shared.deleteVoid("/api/classifieds/\(id)")
            listings.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

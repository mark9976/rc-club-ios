import Foundation
import Observation

@Observable
@MainActor
final class PhotosViewModel {
    var photos: [Photo] = []
    var pendingQueue: [Photo] = []
    var isLoading = false
    var isLoadingQueue = false
    var isUploading = false
    var errorMessage: String?

    private struct PhotoIdBody: Encodable { let id: String }

    func loadPhotos() async {
        isLoading = true
        errorMessage = nil
        do {
            photos = try await APIClient.shared.get("/api/photos/recent")
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadPendingQueue() async {
        isLoadingQueue = true
        errorMessage = nil
        do {
            pendingQueue = try await APIClient.shared.get("/api/photos/queue")
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingQueue = false
    }

    func upload(data: Data, filename: String) async -> Bool {
        isUploading = true
        defer { isUploading = false }
        do {
            let photo: Photo = try await APIClient.shared.upload(
                "/api/photos/upload",
                data: data,
                fieldName: "photo",
                filename: filename,
                mimeType: "image/jpeg"
            )
            photos.insert(photo, at: 0)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // The server treats approve/reject as two distinct endpoints, each
    // taking just {"id"} — no approved/status field on either. Sending a
    // contradictory field (e.g. approved:false to /approve) is now rejected
    // with a 400 rather than silently approving, so the two paths must stay
    // genuinely separate here rather than a single call with a flag.
    func approve(_ photoId: String, approved: Bool) async {
        let path = approved ? "/api/photos/approve" : "/api/photos/reject"
        do {
            let _: Empty = try await APIClient.shared.post(path, body: PhotoIdBody(id: photoId))
            pendingQueue.removeAll { $0.id == photoId }
            if approved {
                await loadPhotos()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

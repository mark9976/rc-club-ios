import SwiftUI

struct PhotoGalleryView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = PhotosViewModel()
    @State private var showUpload = false
    @State private var showQueue = false
    @State private var selectedPhoto: Photo?

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    private var isAdmin: Bool { appState.currentUser?.isAdmin ?? false }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.photos.isEmpty {
                LoadingView()
            } else if viewModel.photos.isEmpty {
                EmptyStateView(
                    icon: "photo.on.rectangle",
                    title: "No photos yet",
                    message: "Share a photo from the field."
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(viewModel.photos) { photo in
                            Button {
                                selectedPhoto = photo
                            } label: {
                                AsyncImageLoader(url: URL(string: photo.url), contentMode: .fill)
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .refreshable { await viewModel.loadPhotos() }
            }
        }
        .toolbar {
            if isAdmin {
                ToolbarItem(placement: .primaryAction) {
                    Button { showQueue = true } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "tray.full")
                            BadgeView(count: viewModel.pendingQueue.count)
                                .offset(x: 10, y: -8)
                        }
                    }
                    .accessibilityLabel("Photo Queue")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button { showUpload = true } label: { Image(systemName: "camera") }
            }
        }
        .sheet(isPresented: $showUpload) {
            PhotoUploadView(viewModel: viewModel)
        }
        .sheet(isPresented: $showQueue) {
            PhotoQueueView(viewModel: viewModel)
        }
        .fullScreenCover(item: $selectedPhoto) { photo in
            PhotoFullScreenView(photos: viewModel.photos, selected: photo)
        }
        .task {
            await viewModel.loadPhotos()
            if isAdmin {
                await viewModel.loadPendingQueue()
            }
        }
    }
}

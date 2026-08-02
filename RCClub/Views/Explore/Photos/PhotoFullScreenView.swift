import SwiftUI

struct PhotoFullScreenView: View {
    @Environment(\.dismiss) private var dismiss
    let photos: [Photo]
    @State private var currentId: Int

    init(photos: [Photo], selected: Photo) {
        self.photos = photos
        _currentId = State(initialValue: selected.id)
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $currentId) {
                ForEach(photos) { photo in
                    AsyncImageLoader(url: URL(string: photo.url), contentMode: .fit)
                        .tag(photo.id)
                }
            }
            .tabViewStyle(.page)
            .background(Color.black)
            .ignoresSafeArea()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

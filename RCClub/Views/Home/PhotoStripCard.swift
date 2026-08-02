import SwiftUI

struct PhotoStripCard: View {
    let photos: [Photo]
    var onSelect: ((Photo) -> Void)?

    var body: some View {
        CardView {
            Text("Recent Photos")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(photos) { photo in
                        Button {
                            onSelect?(photo)
                        } label: {
                            AsyncImageLoader(url: URL(string: photo.url), contentMode: .fill, cornerRadius: 12)
                                .frame(width: 96, height: 96)
                                .clipped()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

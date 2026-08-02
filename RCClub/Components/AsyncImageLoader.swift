import SwiftUI

struct AsyncImageLoader: View {
    let url: URL?
    var contentMode: ContentMode = .fill
    var cornerRadius: CGFloat = 0

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: contentMode)
            case .failure:
                placeholder(systemImage: "photo")
            case .empty:
                placeholder(systemImage: nil)
                    .overlay { ProgressView() }
            @unknown default:
                placeholder(systemImage: "photo")
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private func placeholder(systemImage: String?) -> some View {
        ZStack {
            Color(uiColor: .tertiarySystemFill)
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

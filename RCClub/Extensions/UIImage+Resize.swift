import UIKit

extension UIImage {
    /// Downscales to fit within `maxDimension` on the longest side and
    /// re-encodes as JPEG. Camera captures and full-resolution library photos
    /// can be several MB, well past nginx's default 1MB body-size limit —
    /// this keeps uploads small without a visible quality loss in a gallery.
    func downscaledJPEGData(maxDimension: CGFloat = 1600, quality: CGFloat = 0.75) -> Data? {
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension else {
            return jpegData(compressionQuality: quality)
        }

        let scale = maxDimension / longestSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let resized = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}

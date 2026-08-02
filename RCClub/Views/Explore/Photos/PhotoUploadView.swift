import SwiftUI
import PhotosUI
import UIKit

struct PhotoUploadView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: PhotosViewModel

    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 48))
                            Text("Choose a Photo")
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                    }
                }

                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(Color.dangerRed)
                }

                Text("Uploaded photos are reviewed by a club admin before appearing in the gallery.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding()
            .navigationTitle("Upload Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Upload") {
                        Task {
                            guard let imageData else { return }
                            let success = await viewModel.upload(
                                data: imageData,
                                filename: "upload-\(UUID().uuidString).jpg"
                            )
                            if success { dismiss() }
                        }
                    }
                    .disabled(imageData == nil || viewModel.isUploading)
                }
            }
            .onChange(of: selectedItem) { _, item in
                Task {
                    imageData = try? await item?.loadTransferable(type: Data.self)
                }
            }
        }
    }
}

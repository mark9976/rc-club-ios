import SwiftUI
import PhotosUI
import UIKit

struct PhotoUploadView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: PhotosViewModel
    /// When true, jumps straight into the camera as soon as this view appears
    /// (used by the Home tab's camera shortcut) instead of showing the picker first.
    var autoLaunchCamera: Bool = false
    /// When true, only camera capture is offered — no photo library picker
    /// (used by the Home tab's camera shortcut).
    var cameraOnly: Bool = false

    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let capturedData = imageData, let uiImage = UIImage(data: capturedData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    Button(cameraOnly ? "Retake Photo" : "Retake or Choose a Different Photo") {
                        imageData = nil
                        selectedItem = nil
                        if cameraOnly { showCamera = true }
                    }
                    .font(.subheadline)
                } else if cameraOnly {
                    if !CameraCaptureView.isAvailable {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("Camera isn't available on this device.")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 140)
                    }
                    // Otherwise: nothing to show here — the camera sheet is
                    // already covering the screen via autoLaunchCamera.
                } else {
                    VStack(spacing: 12) {
                        if CameraCaptureView.isAvailable {
                            Button {
                                showCamera = true
                            } label: {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                    Text("Take Photo")
                                }
                                .frame(maxWidth: .infinity, minHeight: 140)
                                .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                            }
                        }

                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 40))
                                Text("Choose a Photo")
                            }
                            .frame(maxWidth: .infinity, minHeight: 140)
                            .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                        }
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
            .fullScreenCover(isPresented: $showCamera) {
                CameraCaptureView { image in
                    imageData = image.jpegData(compressionQuality: 0.85)
                    showCamera = false
                } onCancel: {
                    showCamera = false
                    if cameraOnly && imageData == nil {
                        dismiss()
                    }
                }
                .ignoresSafeArea()
            }
            .task {
                if autoLaunchCamera && imageData == nil && CameraCaptureView.isAvailable {
                    showCamera = true
                }
            }
        }
    }
}

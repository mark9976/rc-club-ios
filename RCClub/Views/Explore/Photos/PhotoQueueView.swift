import SwiftUI

struct PhotoQueueView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: PhotosViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoadingQueue && viewModel.pendingQueue.isEmpty {
                    LoadingView()
                } else if viewModel.pendingQueue.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.circle",
                        title: "All caught up",
                        message: "No photos waiting for review."
                    )
                } else {
                    List {
                        if let error = viewModel.errorMessage {
                            Text(error).foregroundStyle(Color.dangerRed)
                        }
                        ForEach(viewModel.pendingQueue) { photo in
                            PhotoQueueRow(photo: photo) { approved in
                                await viewModel.approve(photo.id, approved: approved)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable { await viewModel.loadPendingQueue() }
                }
            }
            .navigationTitle("Photo Queue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task { await viewModel.loadPendingQueue() }
        }
    }
}

private struct PhotoQueueRow: View {
    let photo: Photo
    let onDecision: (Bool) async -> Void
    @State private var isProcessing = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImageLoader(url: URL(string: photo.url), contentMode: .fill, cornerRadius: 10)
                .frame(width: 80, height: 80)
                .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(photo.uploadedBy)
                    .font(.subheadline.bold())
                if let date = photo.createdAt.asDate {
                    Text(date.relativeTimeString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    Button {
                        decide(true)
                    } label: {
                        Label("Approve", systemImage: "checkmark.circle.fill")
                    }
                    .tint(Color.successGreen)

                    Button(role: .destructive) {
                        decide(false)
                    } label: {
                        Label("Reject", systemImage: "xmark.circle.fill")
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(isProcessing)
            }
        }
        .padding(.vertical, 4)
    }

    private func decide(_ approved: Bool) {
        isProcessing = true
        Task {
            await onDecision(approved)
            isProcessing = false
        }
    }
}

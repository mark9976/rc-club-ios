import SwiftUI

struct MyRequestsView: View {
    var viewModel: LessonsViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.myRequests.isEmpty {
                LoadingView()
            } else if viewModel.myRequests.isEmpty {
                EmptyStateView(
                    icon: "graduationcap",
                    title: "No lesson requests yet",
                    message: "Tap + to request your first lesson."
                )
            } else {
                List(viewModel.myRequests) { request in
                    NavigationLink(value: request) {
                        LessonRow(request: request)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

struct LessonRow: View {
    let request: LessonRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(request.type.replacingOccurrences(of: "_", with: ", ").capitalized)
                .font(.body.weight(.medium))
            HStack {
                statusBadge
                if let instructor = request.instructorName {
                    Text("with \(instructor)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private var statusBadge: some View {
        Text(request.status.capitalized)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(statusColor.opacity(0.15), in: Capsule())
            .foregroundStyle(statusColor)
    }

    private var statusColor: Color {
        switch LessonStatus(rawValue: request.status) {
        case .pending: .warningOrange
        case .accepted, .scheduled: .accentTeal
        case .completed: .successGreen
        case .none: .secondary
        }
    }
}

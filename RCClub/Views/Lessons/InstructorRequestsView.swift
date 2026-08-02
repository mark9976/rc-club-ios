import SwiftUI

struct InstructorRequestsView: View {
    var viewModel: LessonsViewModel

    var body: some View {
        List {
            Section("Incoming Requests") {
                if viewModel.incomingRequests.isEmpty {
                    Text("No open requests").foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.incomingRequests) { request in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(request.studentName).font(.body.weight(.medium))
                            Text("\(request.type.replacingOccurrences(of: "_", with: ", ").capitalized) · \(request.experienceLevel.capitalized)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let notes = request.notes {
                                Text(notes).font(.caption)
                            }
                            HStack {
                                Button("Accept") {
                                    Task { await viewModel.accept(request.id) }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color.accentTeal)
                                Button("Pass") {
                                    viewModel.pass(request.id)
                                }
                                .buttonStyle(.bordered)
                            }
                            .controlSize(.small)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section("My Students") {
                if viewModel.myStudents.isEmpty {
                    Text("No students yet").foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.myStudents) { request in
                        NavigationLink(value: request) {
                            LessonRow(request: request)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

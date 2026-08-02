import SwiftUI

struct LessonDetailView: View {
    @Environment(AppState.self) private var appState
    let request: LessonRequest
    var viewModel: LessonsViewModel

    @State private var scheduledDate = Date()

    private var isInstructorView: Bool {
        appState.currentUser?.isInstructor == true
    }

    var body: some View {
        Form {
            Section("Lesson") {
                LabeledContent("Type", value: request.type.replacingOccurrences(of: "_", with: ", ").capitalized)
                LabeledContent("Experience", value: request.experienceLevel.capitalized)
                if let times = request.preferredTimes {
                    LabeledContent("Preferred Times", value: times)
                }
                if let notes = request.notes {
                    LabeledContent("Notes", value: notes)
                }
                LabeledContent("Status", value: request.status.capitalized)
            }

            if let instructor = request.instructorName {
                Section("Instructor") {
                    Text(instructor)
                }
            }

            if let scheduled = request.scheduledDate {
                Section("Scheduled") {
                    Text(scheduled.asDate?.mediumDateString ?? scheduled)
                }
            }

            if isInstructorView && request.status != LessonStatus.completed.rawValue {
                Section("Schedule") {
                    DatePicker("Date & Time", selection: $scheduledDate)
                    Button("Confirm Schedule") {
                        Task {
                            await viewModel.schedule(
                                request.id,
                                date: ISO8601DateFormatter.rcclub.string(from: scheduledDate)
                            )
                        }
                    }
                }

                Section {
                    Button("Mark Complete") {
                        Task { await viewModel.markComplete(request.id) }
                    }
                }
            }
        }
        .navigationTitle("Lesson")
        .navigationBarTitleDisplayMode(.inline)
    }
}

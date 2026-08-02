import SwiftUI

struct RequestLessonView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: LessonsViewModel

    @State private var selectedTypes: Set<LessonType> = []
    @State private var experience: ExperienceLevel = .beginner
    @State private var preferredTimes = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Aircraft Type") {
                    ForEach(LessonType.allCases) { type in
                        Toggle(type.label, isOn: Binding(
                            get: { selectedTypes.contains(type) },
                            set: { isOn in
                                if isOn { selectedTypes.insert(type) } else { selectedTypes.remove(type) }
                            }
                        ))
                    }
                }

                Section("Experience Level") {
                    Picker("Experience", selection: $experience) {
                        ForEach(ExperienceLevel.allCases) { level in
                            Text(level.label).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Preferred Dates/Times") {
                    TextField("e.g. Saturday mornings", text: $preferredTimes)
                }

                Section("Notes/Goals") {
                    TextField("What would you like to work on?", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }

                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(Color.dangerRed)
                }
            }
            .navigationTitle("Request a Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        Task {
                            let success = await viewModel.submitRequest(
                                types: Array(selectedTypes),
                                experience: experience,
                                preferredTimes: preferredTimes,
                                notes: notes
                            )
                            if success { dismiss() }
                        }
                    }
                    .disabled(selectedTypes.isEmpty || viewModel.isSubmitting)
                }
            }
        }
    }
}

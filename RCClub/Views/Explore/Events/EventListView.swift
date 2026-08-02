import SwiftUI

struct EventListView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = EventsViewModel()
    @State private var showCreate = false

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.events.isEmpty {
                LoadingView()
            } else if viewModel.events.isEmpty {
                EmptyStateView(icon: "calendar", title: "No upcoming events")
            } else {
                List(viewModel.sortedEvents) { event in
                    NavigationLink(value: event) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title).font(.body.weight(.medium))
                            Text(event.date.asDate?.mediumDateString ?? event.date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable { await viewModel.loadEvents() }
            }
        }
        .navigationDestination(for: Event.self) { event in
            EventDetailView(event: event, viewModel: viewModel)
        }
        .toolbar {
            if appState.currentUser?.isAdmin == true {
                ToolbarItem(placement: .primaryAction) {
                    Button { showCreate = true } label: { Image(systemName: "plus") }
                }
            }
        }
        .sheet(isPresented: $showCreate) {
            EventEditorView(viewModel: viewModel)
        }
        .task { await viewModel.loadEvents() }
    }
}

/// Minimal admin create/edit form for events.
struct EventEditorView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: EventsViewModel
    var editingEvent: Event?

    @State private var title = ""
    @State private var date = Date()
    @State private var time = ""
    @State private var location = ""
    @State private var description = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Time (optional)", text: $time)
                    TextField("Location (optional)", text: $location)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle(editingEvent == nil ? "New Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let dateString = DateFormatter.rcclubDateOnly.string(from: date)
                            if let editingEvent {
                                await viewModel.updateEvent(
                                    editingEvent.id,
                                    title: title,
                                    date: dateString,
                                    time: time.isEmpty ? nil : time,
                                    location: location.isEmpty ? nil : location,
                                    description: description.isEmpty ? nil : description
                                )
                            } else {
                                await viewModel.createEvent(
                                    title: title,
                                    date: dateString,
                                    time: time.isEmpty ? nil : time,
                                    location: location.isEmpty ? nil : location,
                                    description: description.isEmpty ? nil : description
                                )
                            }
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let editingEvent {
                    title = editingEvent.title
                    date = editingEvent.date.asDate ?? Date()
                    time = editingEvent.time ?? ""
                    location = editingEvent.location ?? ""
                    description = editingEvent.description ?? ""
                }
            }
        }
    }
}

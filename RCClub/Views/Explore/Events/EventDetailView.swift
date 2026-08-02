import SwiftUI
@preconcurrency import EventKit

struct EventDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let event: Event
    var viewModel: EventsViewModel?

    @State private var showingCalendarAlert = false
    @State private var calendarMessage = ""
    @State private var showEditor = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(event.title)
                    .font(.title.bold())

                VStack(alignment: .leading, spacing: 8) {
                    Label(event.date.asDate?.mediumDateString ?? event.date, systemImage: "calendar")
                    if let time = event.time {
                        Label(time, systemImage: "clock")
                    }
                    if let location = event.location {
                        Label(location, systemImage: "mappin.and.ellipse")
                    }
                }
                .foregroundStyle(.secondary)

                if let description = event.description {
                    Text(description)
                        .font(.body)
                        .padding(.top, 4)
                }

                Button {
                    addToCalendar()
                } label: {
                    Label("Add to Calendar", systemImage: "calendar.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.accentTeal)
                .padding(.top, 12)

                if appState.currentUser?.isAdmin == true, let viewModel {
                    HStack {
                        Button("Edit") { showEditor = true }
                            .buttonStyle(.bordered)
                        Button("Delete", role: .destructive) {
                            Task {
                                await viewModel.deleteEvent(event.id)
                                dismiss()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Calendar", isPresented: $showingCalendarAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(calendarMessage)
        }
        .sheet(isPresented: $showEditor) {
            if let viewModel {
                EventEditorView(viewModel: viewModel, editingEvent: event)
            }
        }
    }

    private func addToCalendar() {
        let store = EKEventStore()
        store.requestFullAccessToEvents { granted, _ in
            DispatchQueue.main.async {
                guard granted else {
                    calendarMessage = "Enable calendar access in Settings to add this event."
                    showingCalendarAlert = true
                    return
                }
                let ekEvent = EKEvent(eventStore: store)
                ekEvent.title = event.title
                ekEvent.notes = event.description
                ekEvent.location = event.location
                let startDate = event.date.asDate ?? Date()
                ekEvent.startDate = startDate
                ekEvent.endDate = startDate.addingTimeInterval(3600)
                ekEvent.calendar = store.defaultCalendarForNewEvents
                do {
                    try store.save(ekEvent, span: .thisEvent)
                    calendarMessage = "Added to your calendar."
                } catch {
                    calendarMessage = "Couldn't add to calendar: \(error.localizedDescription)"
                }
                showingCalendarAlert = true
            }
        }
    }
}

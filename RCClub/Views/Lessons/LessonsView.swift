import SwiftUI

struct LessonsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = LessonsViewModel()
    @State private var showRequestForm = false

    var body: some View {
        NavigationStack {
            Group {
                if let user = appState.currentUser {
                    if user.isInstructor {
                        InstructorRequestsView(viewModel: viewModel)
                    } else {
                        MyRequestsView(viewModel: viewModel)
                    }
                } else {
                    LoadingView()
                }
            }
            .background(Color.screenBackground)
            .navigationTitle("Lessons")
            .toolbar {
                if let user = appState.currentUser, !user.isInstructor {
                    ToolbarItem(placement: .primaryAction) {
                        Button { showRequestForm = true } label: { Image(systemName: "plus") }
                    }
                }
            }
            .navigationDestination(for: LessonRequest.self) { request in
                LessonDetailView(request: request, viewModel: viewModel)
            }
            .sheet(isPresented: $showRequestForm) {
                RequestLessonView(viewModel: viewModel)
            }
            .refreshable {
                if let user = appState.currentUser {
                    await viewModel.load(for: user)
                }
            }
        }
        .task {
            if let user = appState.currentUser {
                await viewModel.load(for: user)
            }
        }
    }
}

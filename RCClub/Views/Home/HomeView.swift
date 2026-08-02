import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = HomeViewModel()
    @State private var selectedPhoto: Photo?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let status = viewModel.fieldStatus {
                        FieldStatusCard(
                            status: status,
                            isCheckedIn: appState.isCheckedIn,
                            isToggling: viewModel.isTogglingCheckIn
                        ) {
                            Task {
                                guard let userId = appState.currentUser?.id else { return }
                                await viewModel.toggleCheckIn(userId: userId, appState: appState)
                            }
                        }
                    }

                    if let weather = viewModel.weather {
                        WeatherCard(weather: weather, forecastDays: viewModel.forecastDays)
                    }

                    if let event = viewModel.nextEvent {
                        NextEventCard(event: event)
                    }

                    if !viewModel.recentPhotos.isEmpty {
                        PhotoStripCard(photos: viewModel.recentPhotos) { photo in
                            selectedPhoto = photo
                        }
                    }

                    if viewModel.isLoading && viewModel.fieldStatus == nil {
                        LoadingView()
                            .frame(height: 200)
                    } else if !viewModel.isLoading && viewModel.fieldStatus == nil {
                        EmptyStateView(
                            icon: "wifi.slash",
                            title: "Couldn't load your club",
                            message: viewModel.errorMessage,
                            actionTitle: "Try Again"
                        ) {
                            Task { await viewModel.loadAll() }
                        }
                        .frame(height: 300)
                    }
                }
                .padding()
            }
            .background(Color.screenBackground)
            .navigationTitle("Home")
            .refreshable { await viewModel.loadAll() }
            .navigationDestination(for: Event.self) { event in
                EventDetailView(event: event)
            }
            .fullScreenCover(item: $selectedPhoto) { photo in
                PhotoFullScreenView(photos: viewModel.recentPhotos, selected: photo)
            }
        }
        .task { await viewModel.loadAll() }
    }
}

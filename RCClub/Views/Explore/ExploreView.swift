import SwiftUI

enum ExploreSection: String, CaseIterable, Identifiable {
    case events = "Events"
    case classifieds = "Classifieds"
    case newsletter = "Newsletter"
    case photos = "Photos"

    var id: String { rawValue }
}

struct ExploreView: View {
    @State private var section: ExploreSection = .events

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Section", selection: $section) {
                    ForEach(ExploreSection.allCases) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Group {
                    switch section {
                    case .events: EventListView()
                    case .classifieds: ClassifiedListView()
                    case .newsletter: NewsletterListView()
                    case .photos: PhotoGalleryView()
                    }
                }
            }
            .background(Color.screenBackground)
            .navigationTitle("Explore")
        }
    }
}

import SwiftUI

struct NewsletterListView: View {
    @State private var viewModel = NewsletterViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.newsletters.isEmpty {
                LoadingView()
            } else if viewModel.newsletters.isEmpty {
                EmptyStateView(icon: "newspaper", title: "No newsletters yet")
            } else {
                List(viewModel.sortedNewsletters) { newsletter in
                    NavigationLink(value: newsletter) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(newsletter.title).font(.body.weight(.medium))
                            Text(newsletter.date.asDate?.mediumDateString ?? newsletter.date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable { await viewModel.loadNewsletters() }
            }
        }
        .navigationDestination(for: Newsletter.self) { newsletter in
            NewsletterReaderView(newsletter: newsletter)
        }
        .task { await viewModel.loadNewsletters() }
    }
}

import SwiftUI

struct ClassifiedListView: View {
    @State private var viewModel = ClassifiedsViewModel()
    @State private var showPostListing = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.listings.isEmpty {
                LoadingView()
            } else if viewModel.filteredListings.isEmpty {
                EmptyStateView(
                    icon: "tag",
                    title: "No listings",
                    message: "Be the first to post something for sale."
                )
            } else {
                ScrollView {
                    categoryFilter
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.filteredListings) { listing in
                            NavigationLink(value: listing) {
                                ClassifiedCard(listing: listing)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .refreshable { await viewModel.loadListings() }
            }
        }
        .navigationDestination(for: ClassifiedListing.self) { listing in
            ClassifiedDetailView(listing: listing, viewModel: viewModel)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showPostListing = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showPostListing) {
            PostListingView(viewModel: viewModel)
        }
        .task { await viewModel.loadListings() }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(nil, label: "All")
                ForEach(ClassifiedCategory.allCases) { category in
                    categoryChip(category, label: category.label)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }

    private func categoryChip(_ category: ClassifiedCategory?, label: String) -> some View {
        Button {
            viewModel.selectedCategory = category
        } label: {
            Text(label)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    viewModel.selectedCategory == category ? Color.accentTeal : Color.cardBackground,
                    in: Capsule()
                )
                .foregroundStyle(viewModel.selectedCategory == category ? .white : .primary)
        }
    }
}

private struct ClassifiedCard: View {
    let listing: ClassifiedListing

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImageLoader(url: listing.photos.first.flatMap(URL.init), contentMode: .fill, cornerRadius: 12)
                .frame(height: 120)
                .clipped()
            Text(listing.title)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
                .foregroundStyle(.primary)
            HStack {
                if let price = listing.price, let priceValue = Double(price) {
                    Text(priceValue, format: .currency(code: "USD"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentTeal)
                }
                if listing.isSold {
                    Text("SOLD")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.dangerRed)
                }
            }
        }
    }
}

import SwiftUI
import UIKit

struct ClassifiedDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let listing: ClassifiedListing
    var viewModel: ClassifiedsViewModel

    private var isOwner: Bool { appState.currentUser?.id == listing.sellerId }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !listing.photos.isEmpty {
                    TabView {
                        ForEach(listing.photos, id: \.self) { url in
                            AsyncImageLoader(url: URL(string: url), contentMode: .fit)
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 280)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(listing.title).font(.title2.bold())
                    HStack {
                        if let price = listing.price, let priceValue = Double(price) {
                            Text(priceValue, format: .currency(code: "USD"))
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Color.accentTeal)
                        }
                        if listing.isSold {
                            Text("SOLD")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.dangerRed)
                        }
                        Spacer()
                        Text(listing.category.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.cardBackground, in: Capsule())
                    }
                    Text(listing.description)
                    Text("Seller: \(listing.sellerName)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                if isOwner {
                    VStack(spacing: 8) {
                        if !listing.isSold {
                            Button("Mark as Sold") {
                                Task {
                                    await viewModel.markSold(listing.id)
                                    dismiss()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.accentTeal)
                            .frame(maxWidth: .infinity)
                        }
                        Button("Delete Listing", role: .destructive) {
                            Task {
                                await viewModel.deleteListing(listing.id)
                                dismiss()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                } else {
                    Button {
                        Task { await contactSeller() }
                    } label: {
                        Label("Contact Seller", systemImage: "envelope.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.accentTeal)
                    .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func contactSeller() async {
        // There's no single-member endpoint — /api/members/{id} 404s. Pull the
        // full roster instead and find the seller in it.
        struct MembersResponse: Decodable { let members: [User] }
        guard let response: MembersResponse = try? await APIClient.shared.get("/api/members"),
              let seller = response.members.first(where: { $0.id == listing.sellerId }),
              !seller.email.isEmpty,
              let url = URL(string: "mailto:\(seller.email)") else { return }
        await UIApplication.shared.open(url)
    }
}

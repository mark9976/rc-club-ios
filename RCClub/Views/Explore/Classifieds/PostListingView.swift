import SwiftUI
import PhotosUI
import UIKit

struct PostListingView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: ClassifiedsViewModel

    @State private var title = ""
    @State private var price = ""
    @State private var category: ClassifiedCategory = .planes
    @State private var description = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var photoData: [Data] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    Picker("Category", selection: $category) {
                        ForEach(ClassifiedCategory.allCases) { c in
                            Text(c.label).tag(c)
                        }
                    }
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...8)
                }

                Section("Photos") {
                    PhotosPicker("Select Photos", selection: $selectedItems, maxSelectionCount: 6, matching: .images)
                    if !photoData.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(photoData.indices, id: \.self) { index in
                                    if let uiImage = UIImage(data: photoData[index]) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 70, height: 70)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                    }
                }

                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(Color.dangerRed)
                }
            }
            .navigationTitle("Post Listing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task {
                            let success = await viewModel.postListing(
                                title: title,
                                price: Double(price),
                                category: category,
                                description: description,
                                photos: photoData
                            )
                            if success { dismiss() }
                        }
                    }
                    .disabled(title.isEmpty || description.isEmpty || viewModel.isPosting)
                }
            }
            .onChange(of: selectedItems) { _, items in
                Task {
                    var data: [Data] = []
                    for item in items {
                        if let loaded = try? await item.loadTransferable(type: Data.self) {
                            data.append(loaded)
                        }
                    }
                    photoData = data
                }
            }
        }
    }
}

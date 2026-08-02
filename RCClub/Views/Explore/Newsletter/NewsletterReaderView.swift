import SwiftUI
import PDFKit

struct NewsletterReaderView: View {
    let newsletter: Newsletter

    var body: some View {
        Group {
            if let url = URL(string: newsletter.fileUrl) {
                PDFReaderView(url: url)
            } else {
                EmptyStateView(icon: "doc", title: "Couldn't load newsletter")
            }
        }
        .navigationTitle(newsletter.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PDFReaderView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.document = PDFDocument(url: url)
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document == nil {
            uiView.document = PDFDocument(url: url)
        }
    }
}

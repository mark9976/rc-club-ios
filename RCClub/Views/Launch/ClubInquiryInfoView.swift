import SwiftUI
import UIKit

struct ClubInquiryInfoView: View {
    @Environment(\.dismiss) private var dismiss

    private let contactEmail = "Mark9976@comcast.net"
    private let contactName = "Mark Kaufmann"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "airplane.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(Color.accentTeal)
                        Text("Is your club on RC Club?")
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)

                    infoSection(
                        title: "What this is",
                        body: "RC Club is a free iOS app for AMA model airplane clubs — one app, many clubs. Members pick their club, sign in, and get everything in one place: live field status, weather/fly-day forecasts, events, classifieds, a photo gallery, lesson requests, and group check-ins with your fellow members."
                    )

                    infoSection(
                        title: "A full website, plus the app",
                        body: "Setup includes a complete website for your club — the same site your members browse on desktop — with the mobile app talking to it live. Update your field status, post an event, or approve a photo once, and it shows up everywhere: your website and every member's phone."
                    )

                    infoSection(
                        title: "What it costs",
                        body: "$50/year, flat. That covers hosting and full setup for both the website and the app — no per-member fees, no ads, no catches. This is a not-for-profit project; the fee just covers what it costs to keep clubs running."
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's included")
                            .font(.headline)
                        bulletPoint("A branded website for your club (your name, logo, colors)")
                        bulletPoint("Your club added to the in-app club directory")
                        bulletPoint("Hosting for both the website and app data")
                        bulletPoint("All the features above, ready to go for your members")
                        bulletPoint("Ongoing updates to both the website and the app")
                    }

                    VStack(spacing: 12) {
                        Text("Want your club added?")
                            .font(.headline)
                        Button {
                            openMail()
                        } label: {
                            Label("Contact \(contactName)", systemImage: "envelope.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.accentTeal)
                        .controlSize(.large)
                        Text(contactEmail)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .padding()
            }
            .background(Color.screenBackground)
            .navigationTitle("Get Your Club Added")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func infoSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(body).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.successGreen)
                .font(.caption)
                .padding(.top, 3)
            Text(text).foregroundStyle(.secondary)
        }
    }

    private func openMail() {
        let subject = "RC Club App — Add My Club"
        let body = "Hi Mark,\n\nI'd like to get my club set up on RC Club. Here's some info about us:\n\nClub name:\nLocation:\nApproximate member count:\n\n"
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = contactEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        if let url = components.url {
            UIApplication.shared.open(url)
        }
    }
}

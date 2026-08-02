import SwiftUI

struct GroupChatView: View {
    @Bindable var viewModel: GroupDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) {
                    if let last = viewModel.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            QuickBroadcastButtons { broadcast in
                Task { await viewModel.sendBroadcast(broadcast) }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            Divider()

            HStack(spacing: 8) {
                TextField("Message", text: $viewModel.messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 18))
                    .lineLimit(1...4)

                Button {
                    Task { await viewModel.sendMessage() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(Color.accentTeal)
                }
                .disabled(viewModel.messageText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(10)
        }
    }
}

private struct MessageBubble: View {
    let message: GroupMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(message.senderName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.accentTeal)
                if message.isBroadcast {
                    Image(systemName: "megaphone.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.warningOrange)
                }
                Spacer()
                Text(message.sentAt.asDate?.timeOfDayString ?? "")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(message.text)
                .font(.body)
        }
        .padding(10)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 12))
    }
}

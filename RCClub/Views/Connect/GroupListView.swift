import SwiftUI

struct GroupListView: View {
    let groups: [RCGroup]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My Groups")
                .font(.title3.bold())

            if isLoading && groups.isEmpty {
                LoadingView().frame(height: 120)
            } else if groups.isEmpty {
                EmptyStateView(
                    icon: "person.2",
                    title: "No groups yet",
                    message: "Create a group to coordinate flying sessions with your friends."
                )
                .frame(height: 160)
            } else {
                ForEach(groups) { group in
                    NavigationLink(value: group) {
                        GroupRow(group: group)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct GroupRow: View {
    let group: RCGroup

    var body: some View {
        CardView {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.accentTeal.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Text(String(group.name.prefix(1)))
                            .font(.headline)
                            .foregroundStyle(Color.accentTeal)
                    }
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.name)
                        .font(.body.weight(.medium))
                    Text("\(group.memberCount) members")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let unread = group.unreadCount, unread > 0 {
                    BadgeView(count: unread)
                }
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }
        }
    }
}

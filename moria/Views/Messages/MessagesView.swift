//
//  MessagesView.swift
//  moria
//
//  Encrypted messaging interface
//

import SwiftUI

struct MessagesView: View {
    @StateObject private var viewModel = MessagesViewModel()
    @State private var showNewMessage = false
    @State private var showNewGroup = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moriaBackground.ignoresSafeArea()

                if viewModel.isLoading {
                    MoriaLoadingView()
                } else if let error = viewModel.error {
                    MoriaErrorView(error: error) {
                        viewModel.loadData()
                    }
                } else {
                    contentView
                }
            }
        }
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: MoriaSpacing.md) {
                // Header with actions
                headerView

                // Groups Section
                if !viewModel.groups.isEmpty {
                    groupsSection
                }

                // Conversations Section
                conversationsSection
            }
            .padding(MoriaSpacing.md)
        }
    }

    private var headerView: some View {
        HStack {
            Text("ENCRYPTED COMMS")
                .font(MoriaFont.title3)
                .foregroundColor(.moriaText)

            Spacer()

            HStack(spacing: MoriaSpacing.sm) {
                Button {
                    showNewGroup = true
                } label: {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.moriaTextSecondary)
                }

                Button {
                    showNewMessage = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16))
                        .foregroundColor(.moriaPrimary)
                }
            }
        }
        .padding(.bottom, MoriaSpacing.sm)
    }

    private var groupsSection: some View {
        VStack(alignment: .leading, spacing: MoriaSpacing.sm) {
            Text("GROUPS")
                .font(MoriaFont.caption)
                .foregroundColor(.moriaTextSecondary)
                .padding(.horizontal, MoriaSpacing.sm)

            ForEach(viewModel.groups) { group in
                GroupRow(group: group)
            }
        }
    }

    private var conversationsSection: some View {
        VStack(alignment: .leading, spacing: MoriaSpacing.sm) {
            Text("DIRECT MESSAGES")
                .font(MoriaFont.caption)
                .foregroundColor(.moriaTextSecondary)
                .padding(.horizontal, MoriaSpacing.sm)

            if viewModel.conversations.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.conversations) { conversation in
                    ConversationRow(conversation: conversation)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: MoriaSpacing.md) {
            Image(systemName: "message.badge.filled.fill")
                .font(.system(size: 32))
                .foregroundColor(.moriaTextTertiary)

            Text("NO CONVERSATIONS")
                .font(MoriaFont.caption)
                .foregroundColor(.moriaTextSecondary)

            Button("START SECURE CHAT") {
                showNewMessage = true
            }
            .moriaPrimaryButton()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MoriaSpacing.xxl)
        .moriaCard()
    }
}

struct GroupRow: View {
    let group: GroupConversation

    var body: some View {
        HStack(spacing: MoriaSpacing.sm) {
            // Group Avatar
            Circle()
                .fill(Color.moriaSurface)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.moriaPrimary)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(group.name.uppercased())
                    .font(MoriaFont.bodyBold)
                    .foregroundColor(.moriaText)

                if let description = group.description {
                    Text(description)
                        .font(MoriaFont.caption)
                        .foregroundColor(.moriaTextSecondary)
                        .lineLimit(1)
                }

                HStack(spacing: MoriaSpacing.xs) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.moriaTextTertiary)

                    Text("\(group.memberCount) MEMBERS")
                        .font(MoriaFont.caption2)
                        .foregroundColor(.moriaTextTertiary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.moriaTextTertiary)
        }
        .padding(MoriaSpacing.sm)
        .moriaCard()
    }
}

struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: MoriaSpacing.sm) {
            // User Avatar
            Circle()
                .fill(Color.moriaSurface)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(conversation.otherUsername.prefix(1).uppercased())
                        .font(MoriaFont.bodyBold)
                        .foregroundColor(.moriaPrimary)
                )

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(conversation.otherUsername.uppercased())
                        .font(MoriaFont.bodyBold)
                        .foregroundColor(.moriaText)

                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(MoriaFont.caption2)
                            .foregroundColor(.moriaBackground)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.moriaPrimary)
                            .cornerRadius(MoriaRadius.sm)
                    }
                }

                if conversation.lastMessage != nil {
                    Text("E2EE MESSAGE")
                        .font(MoriaFont.caption)
                        .foregroundColor(.moriaTextSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage.createdAt.formatted(.relative(presentation: .numeric)))
                        .font(MoriaFont.caption2)
                        .foregroundColor(.moriaTextTertiary)
                }

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.moriaSuccess)
            }
        }
        .padding(MoriaSpacing.sm)
        .moriaCard()
    }
}

#Preview {
    MessagesView()
}

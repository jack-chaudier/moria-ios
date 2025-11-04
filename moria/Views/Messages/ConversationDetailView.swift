//
//  ConversationDetailView.swift
//  moria
//
//  Secure E2EE messaging conversation view
//

import SwiftUI

struct ConversationDetailView: View {
    let conversation: Conversation
    @ObservedObject var viewModel: MessagesViewModel
    @State private var messageText: String = ""
    @State private var isTyping: Bool = false
    @FocusState private var isInputFocused: Bool

    init(conversation: Conversation, viewModel: MessagesViewModel) {
        self.conversation = conversation
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            Color.moriaBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: MoriaSpacing.sm) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isFromCurrentUser: message.senderId != conversation.otherUserId
                                )
                                .id(message.id)
                                .onAppear {
                                    // Mark message as read when it appears
                                    if message.readAt == nil && message.senderId == conversation.otherUserId {
                                        Task {
                                            await viewModel.markMessageAsRead(messageId: message.id)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(MoriaSpacing.md)
                    }
                    .refreshable {
                        await viewModel.loadConversationMessages()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        // Scroll to bottom when new message arrives
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Typing Indicator
                if isTyping {
                    HStack(spacing: MoriaSpacing.xs) {
                        Text("\(conversation.otherUsername) is typing")
                            .font(MoriaFont.caption)
                            .foregroundColor(.moriaTextSecondary)

                        TypingDotsView()
                    }
                    .padding(.horizontal, MoriaSpacing.md)
                    .padding(.vertical, MoriaSpacing.xs)
                }

                // Input Area
                messageInputView
            }
        }
        .navigationTitle(conversation.otherUsername.uppercased())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.selectedConversation = conversation
            Task {
                await viewModel.loadConversationMessages()
            }
        }
    }

    private var messageInputView: some View {
        HStack(spacing: MoriaSpacing.sm) {
            // Text Input
            TextField("Encrypted message", text: $messageText, axis: .vertical)
                .textFieldStyle(.plain)
                .font(MoriaFont.body)
                .foregroundColor(.moriaText)
                .padding(MoriaSpacing.sm)
                .background(Color.moriaSurface)
                .cornerRadius(MoriaRadius.md)
                .focused($isInputFocused)
                .lineLimit(1...5)
                .onChange(of: messageText) { newValue in
                    handleTypingIndicator(isTyping: !newValue.isEmpty)
                }

            // Send Button
            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(messageText.isEmpty ? .moriaTextTertiary : .moriaPrimary)
            }
            .disabled(messageText.isEmpty)
        }
        .padding(MoriaSpacing.md)
        .background(Color.moriaSurface)
        .overlay(
            Rectangle()
                .fill(Color.moriaBorder)
                .frame(height: 1),
            alignment: .top
        )
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let text = messageText
        messageText = ""
        isInputFocused = false

        Task {
            await viewModel.sendMessage(text: text)
        }
    }

    private func handleTypingIndicator(isTyping: Bool) {
        Task {
            do {
                if isTyping {
                    try await MessageService.shared.startTyping(conversationId: conversation.id)
                } else {
                    try await MessageService.shared.stopTyping(conversationId: conversation.id)
                }
            } catch {
                print("[FAIL] Failed to send typing indicator: \(error)")
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: MoriaSpacing.xs) {
                // Message Content
                Text(decryptedContent)
                    .font(MoriaFont.body)
                    .foregroundColor(isFromCurrentUser ? .moriaBackground : .moriaText)
                    .padding(MoriaSpacing.sm)
                    .background(isFromCurrentUser ? Color.moriaPrimary : Color.moriaSurface)
                    .cornerRadius(MoriaRadius.md)

                // Metadata
                HStack(spacing: MoriaSpacing.xs) {
                    // Timestamp
                    Text(message.createdAt.formatted(.relative(presentation: .numeric)))
                        .font(MoriaFont.caption2)
                        .foregroundColor(.moriaTextTertiary)

                    // Status (sent/delivered/read)
                    if isFromCurrentUser {
                        if message.readAt != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.moriaSuccess)
                        } else if message.deliveredAt != nil {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 10))
                                .foregroundColor(.moriaTextTertiary)
                        }
                    }

                    // E2EE indicator
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.moriaSuccess)
                }
            }
            .frame(maxWidth: 280, alignment: isFromCurrentUser ? .trailing : .leading)

            if !isFromCurrentUser { Spacer() }
        }
    }

    private var decryptedContent: String {
        // TODO: Implement actual E2EE decryption
        // For now, assume content is already decrypted or plain text
        if let contentString = String(data: message.encryptedContent, encoding: .utf8) {
            return contentString
        }
        return "[Encrypted Message]"
    }
}

struct TypingDotsView: View {
    @State private var animationPhase = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.moriaTextSecondary)
                    .frame(width: 4, height: 4)
                    .opacity(animationPhase == index ? 1.0 : 0.3)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: false)) {
                animationPhase = (animationPhase + 1) % 3
            }
        }
    }
}

#Preview {
    NavigationStack {
        ConversationDetailView(
            conversation: Conversation(
                id: "preview",
                otherUserId: "user-123",
                otherUsername: "alice",
                lastMessage: nil,
                unreadCount: 0
            ),
            viewModel: MessagesViewModel()
        )
    }
}

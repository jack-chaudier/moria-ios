//
//  MessagesViewModel.swift
//  moria
//
//  Messages view model
//

import Foundation
import Combine

@MainActor
final class MessagesViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var groups: [GroupConversation] = []
    @Published var selectedConversation: Conversation?
    @Published var selectedGroup: GroupConversation?
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var error: String?

    private let messageService = MessageService.shared
    private let wsClient = WebSocketClient.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupWebSocketListeners()
        loadData()
    }

    private func setupWebSocketListeners() {
        // Listen for new messages
        wsClient.messageReceived
            .sink { [weak self] data in
                self?.handleNewMessage(data)
            }
            .store(in: &cancellables)

        // Listen for typing indicators
        wsClient.typingUpdate
            .sink { [weak self] data in
                self?.handleTypingUpdate(data)
            }
            .store(in: &cancellables)
    }

    private func handleNewMessage(_ data: [String: Any]) {
        print("[INFO] New message received: \(data)")
        // Reload messages for current conversation
        Task {
            await loadConversationMessages()
        }
    }

    private func handleTypingUpdate(_ data: [String: Any]) {
        // TODO: Update typing indicator state based on data
        // Expected format: { "user_id": "...", "conversation_id": "...", "is_typing": true }
        print("[INFO] Typing update: \(data)")

        guard let conversationId = data["conversation_id"] as? String,
              conversationId == selectedConversation?.id else {
            return
        }

        // Update typing state in UI
        // This would set the isTyping state in the ConversationDetailView
    }

    func loadData() {
        Task {
            await loadGroups()
            // TODO: Load conversations list
        }
    }

    func loadGroups() async {
        isLoading = true
        error = nil

        do {
            groups = try await messageService.getGroups()
            isLoading = false
        } catch {
            isLoading = false

            // Log detailed error
            print("\u{001B}[31m[FAIL]\u{001B}[0m Failed to load groups: \(error)")

            // If it's a 404, the endpoint doesn't exist yet - just show empty state
            if case APIError.serverError(let statusCode) = error, statusCode == 404 {
                print("\u{001B}[33m[WARN]\u{001B}[0m Groups endpoint not implemented yet - showing empty state")
                groups = []
                // Don't set error - just show empty groups
            } else {
                // For other errors, show to user
                self.error = error.localizedDescription
            }
        }
    }

    func loadConversationMessages() async {
        guard let conversationId = selectedConversation?.id else { return }

        do {
            messages = try await messageService.getConversationMessages(
                conversationId: conversationId
            )
        } catch {
            self.error = error.localizedDescription
        }
    }

    func sendMessage(text: String) async {
        // TODO: Implement actual E2EE encryption
        guard let conversationId = selectedConversation?.id else {
            print("[FAIL] No conversation selected")
            return
        }

        // For now, just UTF-8 encode the text
        // In production, this would be E2EE encrypted
        let encryptedContent = text.data(using: .utf8) ?? Data()

        do {
            if let recipientId = selectedConversation?.otherUserId {
                print("[INFO] Sending message to \(recipientId)")
                let sentMessage = try await messageService.sendMessage(
                    recipientId: recipientId,
                    conversationId: conversationId,
                    encryptedContent: encryptedContent
                )

                // Add message to local list immediately for instant feedback
                messages.append(sentMessage)

                print("[PASS] Message sent successfully")
            }
        } catch {
            print("[FAIL] Failed to send message: \(error)")
            self.error = error.localizedDescription
        }
    }

    func markMessageAsRead(messageId: String) async {
        do {
            try await messageService.markAsRead(id: messageId)
        } catch {
            print("[FAIL] Failed to mark message as read: \(error)")
        }
    }

    func createGroup(name: String, description: String?) async {
        do {
            let group = try await messageService.createGroup(
                name: name,
                description: description
            )
            groups.append(group)
        } catch {
            self.error = error.localizedDescription
        }
    }
}

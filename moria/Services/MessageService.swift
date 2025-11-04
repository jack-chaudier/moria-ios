//
//  MessageService.swift
//  moria
//
//  Message API service layer
//

import Foundation

final class MessageService {
    static let shared = MessageService()
    private let apiClient = APIClient.shared

    private init() {}

    // MARK: - Send Messages
    func sendMessage(
        recipientId: String,
        conversationId: String?,
        encryptedContent: Data,
        expiresInSeconds: Int? = nil
    ) async throws -> Message {
        let body: [String: Any] = [
            "recipient_id": recipientId,
            "conversation_id": conversationId as Any,
            "encrypted_content": encryptedContent.base64EncodedString(),
            "expires_in_seconds": expiresInSeconds as Any
        ]

        return try await apiClient.requestWithDict(
            endpoint: "/messages",
            method: .post,
            body: body
        )
    }
    func sendGroupMessage(
        groupId: String,
        encryptedContent: Data
    ) async throws -> Message {
        let body: [String: Any] = [
            "group_conversation_id": groupId,
            "encrypted_content": encryptedContent.base64EncodedString()
        ]

        return try await apiClient.requestWithDict(
            endpoint: "/messages",
            method: .post,
            body: body
        )
    }

    // MARK: - Fetch Messages
    func getConversationMessages(
        conversationId: String,
        limit: Int = 50,
        offset: Int = 0
    ) async throws -> [Message] {
        return try await apiClient.request(
            endpoint: "/messages/conversations/\(conversationId)?limit=\(limit)&offset=\(offset)"
        )
    }
    func getUndeliveredMessages() async throws -> [Message] {
        return try await apiClient.request(
            endpoint: "/messages/undelivered"
        )
    }
    func getMessage(id: String) async throws -> Message {
        return try await apiClient.request(
            endpoint: "/messages/\(id)"
        )
    }

    // MARK: - Message Status
    func markAsDelivered(id: String) async throws {
        try await apiClient.request(
            endpoint: "/messages/\(id)/delivered",
            method: .put
        )
    }
    func markAsRead(id: String) async throws {
        try await apiClient.request(
            endpoint: "/messages/\(id)/read",
            method: .put
        )
    }

    // MARK: - Delete
    func deleteMessage(id: String) async throws {
        try await apiClient.request(
            endpoint: "/messages/\(id)",
            method: .delete
        )
    }

    // MARK: - Groups
    func createGroup(
        name: String,
        description: String?,
        avatarFileId: String? = nil
    ) async throws -> GroupConversation {
        let body: [String: Any] = [
            "name": name,
            "description": description as Any,
            "avatar_file_id": avatarFileId as Any
        ]

        return try await apiClient.requestWithDict(
            endpoint: "/groups",
            method: .post,
            body: body
        )
    }
    func getGroups() async throws -> [GroupConversation] {
        return try await apiClient.request(
            endpoint: "/groups"
        )
    }
    func getGroupMembers(groupId: String) async throws -> [GroupMember] {
        return try await apiClient.request(
            endpoint: "/groups/\(groupId)/members"
        )
    }
    func addGroupMember(
        groupId: String,
        userId: String,
        role: GroupRole = .member
    ) async throws {
        let body: [String: Any] = [
            "user_id": userId,
            "role": role.rawValue
        ]

        try await apiClient.requestWithDict(
            endpoint: "/groups/\(groupId)/members",
            method: .post,
            body: body
        )
    }
    func removeGroupMember(groupId: String, userId: String) async throws {
        try await apiClient.request(
            endpoint: "/groups/\(groupId)/members/\(userId)",
            method: .delete
        )
    }

    // MARK: - Typing Indicators
    func startTyping(conversationId: String) async throws {
        let body = ["conversation_id": conversationId, "is_typing": true] as [String : Any]
        try await apiClient.requestWithDict(
            endpoint: "/realtime/typing",
            method: .post,
            body: body
        )
    }
    func stopTyping(conversationId: String) async throws {
        let body = ["conversation_id": conversationId, "is_typing": false] as [String : Any]
        try await apiClient.requestWithDict(
            endpoint: "/realtime/typing",
            method: .post,
            body: body
        )
    }
    func getTypingIndicators(conversationId: String) async throws -> [TypingIndicator] {
        return try await apiClient.request(
            endpoint: "/realtime/typing/\(conversationId)"
        )
    }
}

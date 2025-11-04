//
//  Message.swift
//  moria
//
//  Encrypted messaging models
//

import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let senderId: String
    let recipientId: String?
    let conversationId: String?
    let groupConversationId: String?
    let encryptedContent: Data
    let delivered: Bool
    let read: Bool
    let deliveredAt: Date?
    let readAt: Date?
    let createdAt: Date
    let expiresAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case senderId = "sender_id"
        case recipientId = "recipient_id"
        case conversationId = "conversation_id"
        case groupConversationId = "group_conversation_id"
        case encryptedContent = "encrypted_content"
        case delivered
        case read
        case deliveredAt = "delivered_at"
        case readAt = "read_at"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
    }
}

struct Conversation: Identifiable {
    let id: String
    let otherUserId: String
    let otherUsername: String
    let lastMessage: Message?
    let unreadCount: Int
}

struct GroupConversation: Identifiable, Codable {
    let id: String
    let name: String
    let description: String?
    let createdBy: String
    let avatarFileId: String?
    let memberCount: Int?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case createdBy = "created_by"
        case avatarFileId = "avatar_file_id"
        case memberCount = "member_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct GroupMember: Identifiable, Codable {
    let userId: String
    let username: String
    let role: GroupRole
    let joinedAt: Date

    var id: String { userId }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username
        case role
        case joinedAt = "joined_at"
    }
}

enum GroupRole: String, Codable {
    case admin
    case member
}

struct TypingIndicator: Codable {
    let userId: String
    let conversationId: String
    let isTyping: Bool
    let startedAt: Date
    let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case conversationId = "conversation_id"
        case isTyping = "is_typing"
        case startedAt = "started_at"
        case expiresAt = "expires_at"
    }
}

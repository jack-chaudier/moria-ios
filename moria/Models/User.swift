//
//  User.swift
//  moria
//
//  User models and authentication
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let username: String
    let email: String?
    let certFingerprint: String?
    let role: UserRole
    let status: UserStatus
    let createdAt: Date
    let lastSeen: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case certFingerprint = "cert_fingerprint"
        case role
        case status
        case createdAt = "created_at"
        case lastSeen = "last_seen"
    }
}

enum UserRole: String, Codable {
    case user
    case admin
}

enum UserStatus: String, Codable {
    case active
    case suspended
    case inactive
}

struct Session: Identifiable, Codable {
    let id: String
    let deviceId: String
    let deviceInfo: String?
    let createdAt: Date
    let expiresAt: Date
    let lastUsedAt: Date
    let isCurrent: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case deviceId = "device_id"
        case deviceInfo = "device_info"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
        case lastUsedAt = "last_used_at"
        case isCurrent = "is_current"
    }
}

// MARK: - Presence

enum PresenceStatus: String, Codable {
    case online
    case away
    case offline
    case busy
}

struct Presence: Codable {
    let userId: String
    let status: PresenceStatus
    let statusMessage: String?
    let lastSeen: Date?
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case status
        case statusMessage = "status_message"
        case lastSeen = "last_seen"
        case updatedAt = "updated_at"
    }
}

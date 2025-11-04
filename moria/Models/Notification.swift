//
//  Notification.swift
//  moria
//
//  Real-time notification models
//

import Foundation

struct MoriaNotification: Identifiable, Codable {
    let id: String
    let userId: String
    let notificationType: NotificationType
    let title: String
    let body: String
    let metadata: [String: String]?
    let read: Bool
    let delivered: Bool
    let createdAt: Date
    let readAt: Date?
    let expiresAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case notificationType = "notification_type"
        case title
        case body
        case metadata
        case read
        case delivered
        case createdAt = "created_at"
        case readAt = "read_at"
        case expiresAt = "expires_at"
    }
}

enum NotificationType: String, Codable {
    case system
    case messageReceived = "message_received"
    case fileShared = "file_shared"
    case securityAlert = "security_alert"
    case breachAlert = "breach_alert"
    case groupInvite = "group_invite"
}

struct SecurityEvent: Identifiable, Codable {
    let id: String
    let userId: String
    let eventType: SecurityEventType
    let severity: SecuritySeverity
    let ipAddress: String?
    let userAgent: String?
    let metadata: [String: String]?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case eventType = "event_type"
        case severity
        case ipAddress = "ip_address"
        case userAgent = "user_agent"
        case metadata
        case createdAt = "created_at"
    }
}

enum SecurityEventType: String, Codable {
    case failedLogin = "failed_login"
    case rateLimitExceeded = "rate_limit_exceeded"
    case mfaFailed = "mfa_failed"
    case suspiciousActivity = "suspicious_activity"
}

enum SecuritySeverity: String, Codable {
    case low
    case medium
    case high
    case critical
}

struct SecurityAlert: Identifiable, Codable {
    let id: String
    let userId: String
    let alertType: SecurityAlertType
    let severity: SecuritySeverity
    let description: String
    let acknowledged: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case alertType = "alert_type"
        case severity
        case description
        case acknowledged
        case createdAt = "created_at"
    }
}

enum SecurityAlertType: String, Codable {
    case bruteForceAttack = "brute_force_attack"
    case accountTakeover = "account_takeover"
    case dosAttack = "dos_attack"
    case dataExfiltration = "data_exfiltration"
}

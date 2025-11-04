//
//  SecurityService.swift
//  moria
//
//  Security, audit, and session management service
//

import Foundation

final class SecurityService {
    static let shared = SecurityService()
    private let apiClient = APIClient.shared

    private init() {}

    // MARK: - Session Management
    func getSessions() async throws -> [Session] {
        return try await apiClient.request(endpoint: "/sessions"
        )
    }
    func revokeSession(id: String) async throws {
        try await apiClient.request(endpoint: "/sessions/\(id)",
            method: .delete
        )
    }
    func revokeOtherSessions() async throws {
        try await apiClient.request(endpoint: "/sessions/revoke-others",
            method: .post
        )
    }
    func revokeAllSessions() async throws {
        try await apiClient.request(endpoint: "/sessions/revoke-all",
            method: .post
        )
    }

    // MARK: - Audit Logs
    func getAuditLogs(
        userId: String? = nil,
        action: String? = nil,
        resourceType: String? = nil,
        resourceId: String? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        limit: Int = 100,
        offset: Int = 0
    ) async throws -> [AuditLog] {
        var params: [String] = ["limit=\(limit)", "offset=\(offset)"]

        if let userId = userId {
            params.append("user_id=\(userId)")
        }
        if let action = action {
            params.append("action=\(action)")
        }
        if let resourceType = resourceType {
            params.append("resource_type=\(resourceType)")
        }
        if let resourceId = resourceId {
            params.append("resource_id=\(resourceId)")
        }
        if let startTime = startTime {
            let formatter = ISO8601DateFormatter()
            params.append("start_time=\(formatter.string(from: startTime))")
        }
        if let endTime = endTime {
            let formatter = ISO8601DateFormatter()
            params.append("end_time=\(formatter.string(from: endTime))")
        }

        let query = params.joined(separator: "&")
        return try await apiClient.request(endpoint: "/audit?\(query)"
        )
    }
    func getMyAuditLogs(limit: Int = 100, offset: Int = 0) async throws -> [AuditLog] {
        return try await apiClient.request(endpoint: "/audit/me?limit=\(limit)&offset=\(offset)"
        )
    }
    func getAuditLogCount() async throws -> Int {
        struct CountResponse: Decodable {
            let count: Int
        }

        let response: CountResponse = try await apiClient.request(endpoint: "/audit/count"
        )
        return response.count
    }

    // MARK: - Security Events & Alerts
    func getSecurityEvents(
        userId: String? = nil,
        eventType: SecurityEventType? = nil,
        severity: SecuritySeverity? = nil,
        limit: Int = 100,
        offset: Int = 0
    ) async throws -> [SecurityEvent] {
        var params: [String] = ["limit=\(limit)", "offset=\(offset)"]

        if let userId = userId {
            params.append("user_id=\(userId)")
        }
        if let eventType = eventType {
            params.append("event_type=\(eventType.rawValue)")
        }
        if let severity = severity {
            params.append("severity=\(severity.rawValue)")
        }

        let query = params.joined(separator: "&")
        return try await apiClient.request(endpoint: "/security/events?\(query)"
        )
    }
    func getSecurityAlerts(
        userId: String? = nil,
        acknowledged: Bool? = nil,
        limit: Int = 100,
        offset: Int = 0
    ) async throws -> [SecurityAlert] {
        var params: [String] = ["limit=\(limit)", "offset=\(offset)"]

        if let userId = userId {
            params.append("user_id=\(userId)")
        }
        if let acknowledged = acknowledged {
            params.append("acknowledged=\(acknowledged)")
        }

        let query = params.joined(separator: "&")
        return try await apiClient.request(endpoint: "/security/alerts?\(query)"
        )
    }
    func acknowledgeAlert(id: String) async throws {
        try await apiClient.request(endpoint: "/security/alerts/\(id)/acknowledge",
            method: .post
        )
    }

    // MARK: - Presence
    func updatePresence(
        status: PresenceStatus,
        statusMessage: String? = nil
    ) async throws {
        let body: [String: Any] = [
            "status": status.rawValue,
            "status_message": statusMessage as Any
        ]

        try await apiClient.requestWithDict(
            endpoint: "/realtime/presence",
            method: .put,
            body: body
        )
    }
    func getPresence(userId: String) async throws -> Presence {
        return try await apiClient.request(endpoint: "/realtime/presence/\(userId)"
        )
    }
    func getBulkPresence(userIds: [String]) async throws -> [Presence] {
        let body = ["user_ids": userIds]

        return try await apiClient.requestWithDict(
            endpoint: "/realtime/presence/bulk",
            method: .post,
            body: body
        )
    }

    // MARK: - Notifications
    func getNotifications(limit: Int = 50) async throws -> [MoriaNotification] {
        return try await apiClient.request(endpoint: "/realtime/notifications?limit=\(limit)"
        )
    }
    func markNotificationAsRead(id: String) async throws {
        try await apiClient.request(endpoint: "/realtime/notifications/\(id)/read",
            method: .put
        )
    }

    // MARK: - MFA
    func setupTOTP() async throws -> TOTPSetupResponse {
        return try await apiClient.request(endpoint: "/mfa/totp/setup",
            method: .post
        )
    }
    func enableTOTP(secret: String, verificationCode: String) async throws {
        let body: [String: Any] = [
            "secret": secret,
            "verification_code": verificationCode
        ]

        try await apiClient.requestWithDict(
            endpoint: "/mfa/totp/enable",
            method: .post,
            body: body
        )
    }
    func verifyMFA(code: String) async throws -> Bool {
        struct VerifyRequest: Encodable {
            let code: String
        }

        struct VerifyResponse: Decodable {
            let valid: Bool
        }

        let response: VerifyResponse = try await apiClient.request(
            endpoint: "/mfa/verify",
            method: .post,
            body: VerifyRequest(code: code)
        )

        return response.valid
    }
    func getMFAMethods() async throws -> [MFAMethod] {
        return try await apiClient.request(endpoint: "/mfa/methods"
        )
    }
    func disableMFAMethod(id: String) async throws {
        try await apiClient.request(endpoint: "/mfa/methods/\(id)/disable",
            method: .post
        )
    }
    func deleteMFAMethod(id: String) async throws {
        try await apiClient.request(endpoint: "/mfa/methods/\(id)",
            method: .delete
        )
    }
    func generateBackupCodes() async throws -> [String] {
        struct BackupCodesResponse: Decodable {
            let backupCodes: [String]

            enum CodingKeys: String, CodingKey {
                case backupCodes = "backup_codes"
            }
        }

        let response: BackupCodesResponse = try await apiClient.request(endpoint: "/mfa/backup-codes",
            method: .post
        )

        return response.backupCodes
    }
}

// MARK: - Additional Models

struct TOTPSetupResponse: Decodable {
    let secret: String
    let uri: String
}

struct MFAMethod: Identifiable, Decodable {
    let id: String
    let methodType: String
    let isPrimary: Bool
    let enabled: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case methodType = "method_type"
        case isPrimary = "is_primary"
        case enabled
        case createdAt = "created_at"
    }
}

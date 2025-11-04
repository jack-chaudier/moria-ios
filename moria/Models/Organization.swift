//
//  Organization.swift
//  moria
//
//  Organization and team management models
//

import Foundation

struct Organization: Identifiable, Codable {
    let id: String
    let name: String
    let createdBy: String
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct OrganizationMember: Identifiable, Codable {
    let organizationId: String
    let userId: String
    let username: String?
    let role: OrganizationRole
    let joinedAt: Date

    var id: String { "\(organizationId)_\(userId)" }

    enum CodingKeys: String, CodingKey {
        case organizationId = "organization_id"
        case userId = "user_id"
        case username
        case role
        case joinedAt = "joined_at"
    }
}

enum OrganizationRole: String, Codable {
    case admin
    case member
}

struct AuditLog: Identifiable, Codable {
    let id: String
    let userId: String
    let action: String
    let resourceType: String?
    let resourceId: String?
    let ipAddress: String?
    let userAgent: String?
    let metadata: [String: String]?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case action
        case resourceType = "resource_type"
        case resourceId = "resource_id"
        case ipAddress = "ip_address"
        case userAgent = "user_agent"
        case metadata
        case createdAt = "created_at"
    }
}

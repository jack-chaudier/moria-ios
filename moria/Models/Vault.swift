//
//  Vault.swift
//  moria
//
//  Password vault and breach monitoring models
//

import Foundation

struct Vault: Identifiable, Codable {
    let id: String
    let userId: String
    let encryptedVault: Data
    let version: Int
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case encryptedVault = "encrypted_vault"
        case version
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct VaultPassword: Identifiable, Codable {
    let id: String
    let userId: String
    let vaultId: String
    let passwordHash: String
    let siteNameEncrypted: Data
    let usernameEncrypted: Data
    let lastChecked: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case vaultId = "vault_id"
        case passwordHash = "password_hash"
        case siteNameEncrypted = "site_name_encrypted"
        case usernameEncrypted = "username_encrypted"
        case lastChecked = "last_checked"
        case createdAt = "created_at"
    }
}

struct BreachAlert: Identifiable, Codable {
    let id: String
    let userId: String
    let vaultPasswordId: String
    let breachName: String
    let breachDate: Date
    let description: String
    let severity: BreachSeverity
    let acknowledged: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case vaultPasswordId = "vault_password_id"
        case breachName = "breach_name"
        case breachDate = "breach_date"
        case description
        case severity
        case acknowledged
        case createdAt = "created_at"
    }
}

enum BreachSeverity: String, Codable {
    case low
    case medium
    case high
    case critical
}

struct PasswordStrength: Codable {
    let strength: Int
    let feedback: String?
}

struct GeneratedPassword: Codable {
    let password: String
    let strength: Int
    let length: Int
}

struct GeneratePasswordRequest: Codable {
    let length: Int
    let includeLowercase: Bool
    let includeUppercase: Bool
    let includeDigits: Bool
    let includeSymbols: Bool
    let excludeAmbiguous: Bool

    enum CodingKeys: String, CodingKey {
        case length
        case includeLowercase = "include_lowercase"
        case includeUppercase = "include_uppercase"
        case includeDigits = "include_digits"
        case includeSymbols = "include_symbols"
        case excludeAmbiguous = "exclude_ambiguous"
    }
}

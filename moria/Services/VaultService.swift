//
//  VaultService.swift
//  moria
//
//  Password vault and breach monitoring service
//

import Foundation

final class VaultService {
    static let shared = VaultService()
    private let apiClient = APIClient.shared

    private init() {}

    // MARK: - Vault Management
    func createVault(encryptedVault: Data) async throws -> Vault {
        let body: [String: Any] = [
            "encrypted_vault": encryptedVault.base64EncodedString()
        ]

        return try await apiClient.requestWithDict(
            endpoint: "/vault",
            method: .post,
            body: body
        )
    }
    func getVault() async throws -> Vault {
        return try await apiClient.request(endpoint: "/vault"
        )
    }
    func updateVault(encryptedVault: Data, version: Int) async throws {
        let body: [String: Any] = [
            "encrypted_vault": encryptedVault.base64EncodedString(),
            "version": version
        ]

        try await apiClient.requestWithDict(
            endpoint: "/vault",
            method: .put,
            body: body
        )
    }
    func deleteVault() async throws {
        try await apiClient.request(endpoint: "/vault",
            method: .delete
        )
    }
    func vaultExists() async throws -> Bool {
        struct ExistsResponse: Decodable {
            let exists: Bool
        }

        let response: ExistsResponse = try await apiClient.request(endpoint: "/vault/exists"
        )
        return response.exists
    }

    // MARK: - Password Generation
    func generatePassword(
        length: Int = 16,
        includeLowercase: Bool = true,
        includeUppercase: Bool = true,
        includeDigits: Bool = true,
        includeSymbols: Bool = true,
        excludeAmbiguous: Bool = true
    ) async throws -> GeneratedPassword {
        let request = GeneratePasswordRequest(
            length: length,
            includeLowercase: includeLowercase,
            includeUppercase: includeUppercase,
            includeDigits: includeDigits,
            includeSymbols: includeSymbols,
            excludeAmbiguous: excludeAmbiguous
        )

        return try await apiClient.request(
            endpoint: "/passwords/generate",
            method: .post,
            body: request
        )
    }
    func generatePIN(length: Int = 6) async throws -> String {
        struct PINRequest: Encodable {
            let length: Int
        }

        struct PINResponse: Decodable {
            let pin: String
        }

        let response: PINResponse = try await apiClient.request(
            endpoint: "/passwords/generate-pin",
            method: .post,
            body: PINRequest(length: length)
        )

        return response.pin
    }
    func checkPasswordStrength(password: String) async throws -> PasswordStrength {
        struct StrengthRequest: Encodable {
            let password: String
        }

        return try await apiClient.request(
            endpoint: "/passwords/strength",
            method: .post,
            body: StrengthRequest(password: password)
        )
    }

    // MARK: - Breach Monitoring
    func checkBreach(
        passwordHash: String,
        vaultPasswordId: String
    ) async throws -> BreachCheckResponse {
        let body: [String: Any] = [
            "password_hash": passwordHash,
            "vault_password_id": vaultPasswordId
        ]

        return try await apiClient.requestWithDict(
            endpoint: "/breach/check",
            method: .post,
            body: body
        )
    }
    func getBreachAlerts(acknowledged: Bool? = nil) async throws -> [BreachAlert] {
        var endpoint = "/breach/alerts"
        if let acknowledged = acknowledged {
            endpoint += "?acknowledged=\(acknowledged)"
        }

        return try await apiClient.request(endpoint: endpoint)
    }
    func acknowledgeBreachAlert(id: String) async throws {
        try await apiClient.request(endpoint: "/breach/alerts/\(id)/acknowledge",
            method: .post
        )
    }
}

struct BreachCheckResponse: Decodable {
    let breached: Bool
    let breachName: String?
    let breachCount: Int
    let recommendation: String?

    enum CodingKeys: String, CodingKey {
        case breached
        case breachName = "breach_name"
        case breachCount = "breach_count"
        case recommendation
    }
}

//
//  APIClient.swift
//  moria
//
//  Military-grade API client for Moria Security Hub
//

import Foundation
import Combine
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case unauthorized
    case rateLimited(retryAfter: Int?)
    case serverError(statusCode: Int)
    case decodingError(Error)
    case encodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized - please login again"
        case .rateLimited(let retryAfter):
            if let retry = retryAfter {
                return "Rate limited - retry after \(retry) seconds"
            }
            return "Rate limited - please wait"
        case .serverError(let code):
            return "Server error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        }
    }
}

final class APIClient: ObservableObject {
    static let shared = APIClient()

    // Configuration
    private let baseURL: String
    private let session: URLSession

    // Authentication state
    @Published var accessToken: String?
    @Published var refreshToken: String?
    @Published var isAuthenticated: Bool = false

    // Device identification
    private let deviceID: String
    private let certificateFingerprint: String

    private init() {
        // Configuration - Production server with Let's Encrypt certificate
        self.baseURL = "https://moria-backend.duckdns.org/api/v1"

        // Configure URLSession - no special handling needed with trusted certificate!
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300

        self.session = URLSession(configuration: config)

        // Device identification
        self.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString

        // In development, use static fingerprint
        // In production, this would be extracted from client certificate
        self.certificateFingerprint = "development-cert-fingerprint"

        // Load stored tokens
        loadTokens()
    }

    // MARK: - Token Management

    private func loadTokens() {
        accessToken = KeychainManager.shared.load(key: "access_token")
        refreshToken = KeychainManager.shared.load(key: "refresh_token")
        isAuthenticated = accessToken != nil
    }

    private func saveTokens(access: String, refresh: String) {
        accessToken = access
        refreshToken = refresh
        isAuthenticated = true

        KeychainManager.shared.save(key: "access_token", value: access)
        KeychainManager.shared.save(key: "refresh_token", value: refresh)
    }

    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        isAuthenticated = false

        KeychainManager.shared.delete(key: "access_token")
        KeychainManager.shared.delete(key: "refresh_token")
    }

    // MARK: - Request Building

    private func buildRequest(
        endpoint: String,
        method: HTTPMethod,
        body: Data? = nil,
        requiresAuth: Bool = true
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(deviceID, forHTTPHeaderField: "X-Device-ID")

        // Add authentication
        if requiresAuth, let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add certificate fingerprint for auth endpoints
        if endpoint.contains("/auth/") {
            request.setValue(certificateFingerprint, forHTTPHeaderField: "X-Client-Cert-Fingerprint")
        }

        if let body = body {
            request.httpBody = body
        }

        return request
    }

    // MARK: - Core Request Methods

    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        // Encode body if present
        var bodyData: Data?
        if let body = body {
            do {
                bodyData = try JSONEncoder().encode(body)
            } catch {
                throw APIError.encodingError(error)
            }
        }

        return try await performRequest(endpoint: endpoint, method: method, bodyData: bodyData, requiresAuth: requiresAuth)
    }

    // Request with dictionary body
    func requestWithDict<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        // Encode body if present
        var bodyData: Data?
        if let body = body {
            do {
                bodyData = try JSONSerialization.data(withJSONObject: body)
            } catch {
                throw APIError.encodingError(error)
            }
        }

        return try await performRequest(endpoint: endpoint, method: method, bodyData: bodyData, requiresAuth: requiresAuth)
    }

    // Core request implementation
    private func performRequest<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        bodyData: Data?,
        requiresAuth: Bool
    ) async throws -> T {

        // Build request
        let request = try buildRequest(
            endpoint: endpoint,
            method: method,
            body: bodyData,
            requiresAuth: requiresAuth
        )

        // Execute request
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            // Handle status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success
                break
            case 401:
                // Unauthorized - token may have expired
                throw APIError.unauthorized
            case 429:
                let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
                throw APIError.rateLimited(retryAfter: retryAfter)
            case 400...499:
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            case 500...599:
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            default:
                throw APIError.invalidResponse
            }

            // Decode response
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // Empty response variant
    func request(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws {
        let _: EmptyResponse = try await request(
            endpoint: endpoint,
            method: method,
            body: body,
            requiresAuth: requiresAuth
        )
    }

    // Empty response variant for dictionaries
    func requestWithDict(
        endpoint: String,
        method: HTTPMethod = .get,
        body: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws {
        let _: EmptyResponse = try await requestWithDict(
            endpoint: endpoint,
            method: method,
            body: body,
            requiresAuth: requiresAuth
        )
    }

    // MARK: - Authentication

    func login() async throws -> LoginResponse {
        let response: LoginResponse = try await request(
            endpoint: "/auth/login",
            method: .post,
            requiresAuth: false
        )

        saveTokens(access: response.accessToken, refresh: response.refreshToken)
        return response
    }

    func refreshAccessToken() async throws {
        guard let refresh = refreshToken else {
            throw APIError.unauthorized
        }

        let body = RefreshTokenRequest(refreshToken: refresh)
        let response: LoginResponse = try await request(
            endpoint: "/auth/refresh",
            method: .post,
            body: body,
            requiresAuth: false
        )

        saveTokens(access: response.accessToken, refresh: response.refreshToken)
    }

    func logout() async throws {
        guard let refresh = refreshToken else { return }

        let body = RefreshTokenRequest(refreshToken: refresh)
        try await request(
            endpoint: "/auth/logout",
            method: .post,
            body: body,
            requiresAuth: false
        )

        clearTokens()
    }

    func verifyToken() async throws -> VerifyResponse {
        return try await request(endpoint: "/auth/verify")
    }
}

// MARK: - Helper Models

struct EmptyResponse: Decodable {}

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

struct RefreshTokenRequest: Encodable {
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

struct VerifyResponse: Decodable {
    let valid: Bool
    let userId: String
    let username: String
    let role: String

    enum CodingKeys: String, CodingKey {
        case valid
        case userId = "user_id"
        case username
        case role
    }
}

// MARK: - Note: No SSL delegate needed with Let's Encrypt trusted certificate!


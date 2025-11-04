//
//  AuthViewModel.swift
//  moria
//
//  Authentication state management
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    @Published var requiresMFA = false
    @Published var currentUser: User?

    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Observe API client authentication state
        apiClient.$isAuthenticated
            .assign(to: &$isAuthenticated)

        // Try to verify existing token on init
        if apiClient.isAuthenticated {
            Task {
                await verifyToken()
            }
        }
    }

    func login() async {
        isLoading = true
        error = nil

        do {
            let response = try await apiClient.login()
            print("\u{001B}[32m[PASS]\u{001B}[0m Login successful")

            // Verify the token and get user info
            await verifyToken()

            // Connect WebSocket for real-time features
            WebSocketClient.shared.connect(accessToken: response.accessToken)

            isLoading = false
        } catch {
            isLoading = false

            // Show friendly error message for rate limiting
            if case APIError.rateLimited(let retryAfter) = error {
                self.error = "Too many requests - please wait \(retryAfter ?? 60) seconds"
            } else {
                self.error = error.localizedDescription
            }

            print("\u{001B}[31m[FAIL]\u{001B}[0m Login failed: \(error)")
        }
    }

    func verifyToken() async {
        do {
            let response = try await apiClient.verifyToken()
            if response.valid {
                // TODO: Fetch full user profile
                print("\u{001B}[32m[PASS]\u{001B}[0m Token valid for user: \(response.username)")
            }
        } catch {
            print("\u{001B}[31m[FAIL]\u{001B}[0m Token verification failed: \(error)")

            // Don't logout on rate limit - just wait
            if case APIError.rateLimited(let retryAfter) = error {
                print("\u{001B}[33m[WARN]\u{001B}[0m Rate limited - retry after \(retryAfter ?? 0) seconds")
                return
            }

            // Only logout on auth errors
            if case APIError.unauthorized = error {
                logout()
            }
        }
    }

    func logout() {
        Task {
            do {
                try await apiClient.logout()
            } catch {
                // Don't spam errors on logout - just log it
                if case APIError.rateLimited = error {
                    print("\u{001B}[33m[WARN]\u{001B}[0m Logout skipped due to rate limit")
                } else {
                    print("\u{001B}[31m[FAIL]\u{001B}[0m Logout error: \(error)")
                }
            }

            // Disconnect WebSocket
            WebSocketClient.shared.disconnect()

            // Clear local state
            currentUser = nil
            isAuthenticated = false
            error = nil
        }
    }

    func refreshToken() async {
        do {
            try await apiClient.refreshAccessToken()
            print("\u{001B}[32m[PASS]\u{001B}[0m Token refreshed")
        } catch {
            print("\u{001B}[31m[FAIL]\u{001B}[0m Token refresh failed: \(error)")
            logout()
        }
    }
}

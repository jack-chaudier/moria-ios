//
//  FileService.swift
//  moria
//
//  Encrypted file management service
//

import Foundation

final class FileService {
    static let shared = FileService()
    private let apiClient = APIClient.shared

    private init() {}

    // MARK: - Files
    func uploadFile(
        filenameEncrypted: Data,
        mimeType: String,
        sizeBytes: Int64,
        storageKey: String,
        encryptedKey: Data,
        checksumEncrypted: String,
        expiresInSeconds: Int? = nil
    ) async throws -> SecureFile {
        let body: [String: Any] = [
            "filename_encrypted": filenameEncrypted.base64EncodedString(),
            "mime_type": mimeType,
            "size_bytes": sizeBytes,
            "storage_key": storageKey,
            "encrypted_key": encryptedKey.base64EncodedString(),
            "checksum_encrypted": checksumEncrypted,
            "expires_in_seconds": expiresInSeconds as Any
        ]

        return try await apiClient.requestWithDict(
            endpoint: "/files",
            method: .post,
            body: body
        )
    }
    func getFiles(limit: Int = 50, offset: Int = 0) async throws -> [SecureFile] {
        return try await apiClient.request(endpoint: "/files?limit=\(limit)&offset=\(offset)"
        )
    }
    func getFile(id: String) async throws -> SecureFile {
        return try await apiClient.request(endpoint: "/files/\(id)"
        )
    }
    func deleteFile(id: String) async throws {
        try await apiClient.request(endpoint: "/files/\(id)",
            method: .delete
        )
    }
    func getStorageUsage() async throws -> Int64 {
        struct StorageResponse: Decodable {
            let storageUsedBytes: Int64

            enum CodingKeys: String, CodingKey {
                case storageUsedBytes = "storage_used_bytes"
            }
        }

        let response: StorageResponse = try await apiClient.request(endpoint: "/files/storage"
        )
        return response.storageUsedBytes
    }

    // MARK: - File Sharing
    func shareFile(
        fileId: String,
        sharedWithId: String,
        encryptedFileKey: Data,
        permission: FilePermission,
        expiresInSeconds: Int? = nil
    ) async throws -> FileShare {
        let body: [String: Any] = [
            "shared_with_id": sharedWithId,
            "encrypted_file_key": encryptedFileKey.base64EncodedString(),
            "permission": permission.rawValue,
            "expires_in_seconds": expiresInSeconds as Any
        ]

        return try await apiClient.requestWithDict(
            endpoint: "/files/\(fileId)/share",
            method: .post,
            body: body
        )
    }
    func getSharedFiles() async throws -> [FileShare] {
        return try await apiClient.request(endpoint: "/files/shared"
        )
    }

    // MARK: - File Versions
    func getFileVersions(fileId: String) async throws -> [FileVersion] {
        return try await apiClient.request(endpoint: "/files/\(fileId)/versions"
        )
    }
    func createFileVersion(
        fileId: String,
        storageKey: String,
        sizeBytes: Int64,
        checksumEncrypted: String
    ) async throws -> FileVersion {
        let body: [String: Any] = [
            "storage_key": storageKey,
            "size_bytes": sizeBytes,
            "checksum_encrypted": checksumEncrypted
        ]

        return try await apiClient.requestWithDict(
            endpoint: "/files/\(fileId)/versions",
            method: .post,
            body: body
        )
    }

    // MARK: - Chunked Upload
    func startChunkedUpload(
        filenameEncrypted: Data,
        totalChunks: Int,
        totalSizeBytes: Int64,
        mimeType: String,
        expiresInHours: Int = 24
    ) async throws -> UploadSession {
        let body: [String: Any] = [
            "filename_encrypted": filenameEncrypted.base64EncodedString(),
            "total_chunks": totalChunks,
            "total_size_bytes": totalSizeBytes,
            "mime_type": mimeType,
            "expires_in_hours": expiresInHours
        ]

        return try await apiClient.requestWithDict(
            endpoint: "/files/upload/start",
            method: .post,
            body: body
        )
    }
    func uploadChunk(
        sessionId: String,
        chunkNumber: Int,
        chunkData: Data,
        checksum: String
    ) async throws {
        let body: [String: Any] = [
            "chunk_number": chunkNumber,
            "chunk_data": chunkData.base64EncodedString(),
            "checksum": checksum
        ]

        try await apiClient.requestWithDict(
            endpoint: "/files/upload/\(sessionId)/chunk",
            method: .post,
            body: body
        )
    }
    func completeChunkedUpload(sessionId: String) async throws -> SecureFile {
        return try await apiClient.request(endpoint: "/files/upload/\(sessionId)/complete",
            method: .post
        )
    }
    func cancelUpload(sessionId: String) async throws {
        try await apiClient.request(endpoint: "/files/upload/\(sessionId)",
            method: .delete
        )
    }
}

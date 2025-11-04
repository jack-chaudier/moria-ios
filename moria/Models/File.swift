//
//  File.swift
//  moria
//
//  Encrypted file management models
//

import Foundation

struct SecureFile: Identifiable, Codable {
    let id: String
    let ownerId: String
    let filenameEncrypted: Data
    let mimeType: String
    let sizeBytes: Int64
    let storageKey: String
    let encryptedKey: Data
    let checksumEncrypted: String
    let currentVersion: Int
    let createdAt: Date
    let expiresAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case ownerId = "owner_id"
        case filenameEncrypted = "filename_encrypted"
        case mimeType = "mime_type"
        case sizeBytes = "size_bytes"
        case storageKey = "storage_key"
        case encryptedKey = "encrypted_key"
        case checksumEncrypted = "checksum_encrypted"
        case currentVersion = "current_version"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
    }
}

struct FileShare: Identifiable, Codable {
    let id: String
    let fileId: String
    let sharedBy: String
    let sharedWith: String
    let encryptedFileKey: Data
    let permission: FilePermission
    let createdAt: Date
    let expiresAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case fileId = "file_id"
        case sharedBy = "shared_by"
        case sharedWith = "shared_with"
        case encryptedFileKey = "encrypted_file_key"
        case permission
        case createdAt = "created_at"
        case expiresAt = "expires_at"
    }
}

enum FilePermission: String, Codable {
    case read
    case write
    case admin
}

struct FileVersion: Identifiable, Codable {
    let id: String
    let fileId: String
    let versionNumber: Int
    let storageKey: String
    let sizeBytes: Int64
    let checksumEncrypted: String
    let createdBy: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case fileId = "file_id"
        case versionNumber = "version_number"
        case storageKey = "storage_key"
        case sizeBytes = "size_bytes"
        case checksumEncrypted = "checksum_encrypted"
        case createdBy = "created_by"
        case createdAt = "created_at"
    }
}

struct UploadSession: Identifiable, Codable {
    let id: String
    let userId: String
    let filenameEncrypted: Data
    let totalChunks: Int
    let chunksUploaded: Int
    let totalSizeBytes: Int64
    let mimeType: String
    let status: UploadStatus
    let createdAt: Date
    let completedAt: Date?
    let expiresAt: Date

    var progress: Double {
        Double(chunksUploaded) / Double(totalChunks)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case filenameEncrypted = "filename_encrypted"
        case totalChunks = "total_chunks"
        case chunksUploaded = "chunks_uploaded"
        case totalSizeBytes = "total_size_bytes"
        case mimeType = "mime_type"
        case status
        case createdAt = "created_at"
        case completedAt = "completed_at"
        case expiresAt = "expires_at"
    }
}

enum UploadStatus: String, Codable {
    case inProgress = "in_progress"
    case completed
    case failed
}

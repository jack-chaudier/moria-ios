# Moria iOS Frontend

Military-grade security hub iOS application for defense and government contractors.

## Overview

The Moria iOS app provides a native SwiftUI interface to the Moria Security Hub backend, featuring:

- **End-to-End Encrypted Messaging**: Signal Protocol-based secure communications
- **Secure File Sharing**: Encrypted file storage with granular permissions
- **Password Vault**: Client-side encrypted password management with breach monitoring
- **Real-Time Features**: WebSocket-powered presence, typing indicators, and notifications
- **Security Dashboard**: Audit logs, session management, and intrusion detection alerts
- **Military-Grade Design**: Minimal, monospace, tactical aesthetic inspired by defense systems

## Architecture

### Project Structure

```
moria/
├── Network/
│   ├── APIClient.swift              # REST API client with JWT auth
│   └── WebSocketClient.swift        # Real-time WebSocket connection
├── Models/
│   ├── User.swift                   # User, Session, Presence models
│   ├── Message.swift                # Message, Conversation, Group models
│   ├── File.swift                   # File, FileShare, Upload models
│   ├── Vault.swift                  # Vault, Password, Breach models
│   ├── Notification.swift           # Notification, SecurityEvent models
│   └── Organization.swift           # Organization, AuditLog models
├── Services/
│   ├── MessageService.swift         # Message API layer
│   ├── FileService.swift            # File management API
│   ├── VaultService.swift           # Password vault API
│   └── SecurityService.swift        # Security, audit, MFA API
├── ViewModels/
│   ├── AuthViewModel.swift          # Authentication state
│   └── MessagesViewModel.swift      # Messages state
├── Views/
│   ├── Authentication/
│   │   └── LoginView.swift          # Certificate-based login
│   ├── Messages/
│   │   └── MessagesView.swift       # Encrypted messaging UI
│   └── MainTabView.swift            # Main navigation
├── Design/
│   └── DesignSystem.swift           # Colors, fonts, components
├── Utilities/
│   └── KeychainManager.swift        # Secure token storage
├── ContentView.swift                # App coordinator
└── moriaApp.swift                   # App entry point
```

## Design System

### Color Palette

**Military Dark Theme** - Inspired by tactical displays and command centers:

- **Background**: `#0a0a0a` - Deep black
- **Surface**: `#111111` - Command panel
- **Card**: `#1a1a1a` - Display modules
- **Primary**: `#00ff41` - Tactical green (encrypted/secure indicators)
- **Secondary**: `#00d4ff` - Info/links
- **Warning**: `#ffaa00` - Caution states
- **Danger**: `#ff0055` - Critical alerts
- **Success**: `#00ff88` - Confirmed/safe

### Typography

**Monospace Font**: Menlo (system monospace)
- Consistent with military/tactical systems
- Clear character distinction for security codes
- Professional, technical aesthetic

**Type Scale**:
- Title 1: 28pt Bold
- Title 2: 22pt Bold
- Title 3: 18pt Semibold
- Headline: 16pt Semibold
- Body: 14pt Regular
- Caption: 12pt Regular

### Components

- **MoriaCard**: Bordered container with surface background
- **MoriaStatusBadge**: Presence indicator (online/away/busy/offline)
- **MoriaSecurityBadge**: Security level indicator (critical/high/medium/low)
- **MoriaLoadingView**: Minimal loading state
- **MoriaErrorView**: Error display with retry action

## Features

### 1. Authentication

**Certificate-Based Authentication** (Development mode uses static fingerprint):

```swift
// Automatic certificate fingerprint extraction
X-Client-Cert-Fingerprint: development-cert-fingerprint
X-Device-ID: <UUID>
```

**JWT Token Management**:
- Access tokens (15 min expiry)
- Refresh tokens (24 hour expiry)
- Automatic token refresh on 401
- Secure keychain storage

**Multi-Factor Authentication**:
- TOTP setup and verification
- Backup codes generation
- Multiple MFA methods per user

### 2. Encrypted Messaging

**Direct Messages**:
- End-to-end encryption
- Read receipts
- Delivery tracking
- Message expiration

**Group Conversations**:
- Multi-user encrypted groups
- Role-based access (admin/member)
- Group avatars
- Member management

**Real-Time Features**:
- Typing indicators (5s auto-expiry)
- Presence status
- Live message delivery
- WebSocket-powered updates

### 3. File Management

**Secure File Storage**:
- Client-side encryption
- Encrypted metadata
- File versioning
- Storage quota tracking

**File Sharing**:
- Granular permissions (read/write/admin)
- Time-based expiration
- Re-encrypted keys per recipient
- Share revocation

**Chunked Uploads**:
- Large file support
- Resume capability
- Progress tracking
- Session management

### 4. Password Vault

**Vault Management**:
- Client-side XChaCha20-Poly1305 encryption
- Version control with optimistic locking
- Server never sees plaintext

**Password Generation**:
- Cryptographically secure (crypto/rand)
- Configurable character sets
- Strength calculation (0-100)
- PIN generation

**Breach Monitoring**:
- HIBP integration (k-anonymity)
- Automatic breach detection
- Breach alerts
- SHA-256 password hashing

### 5. Security Dashboard

**Session Management**:
- View all active sessions
- Device tracking
- Revoke specific sessions
- Revoke all sessions

**Audit Logs**:
- Complete activity history
- Filterable by action, resource, date
- Compliance reporting ready
- Tamper-proof trail

**Intrusion Detection**:
- Brute force detection
- Account takeover alerts
- Rate limit violations
- Data exfiltration monitoring

**Security Alerts**:
- Real-time threat notifications
- Severity levels (low/medium/high/critical)
- Alert acknowledgment
- Automated IDS triggers

### 6. Real-Time Features

**WebSocket Connection**:
- Automatic reconnection
- Ping/pong heartbeat (30s)
- Multi-device support
- Message type routing

**Notifications**:
- System notifications
- Message alerts
- Security alerts
- Breach warnings
- Group invites

**Presence System**:
- Online/away/busy/offline
- Custom status messages
- Last seen timestamps
- Bulk presence queries

## Configuration

### Backend URL

Update in `APIClient.swift`:

```swift
private let baseURL: String = "https://api.moria.example.com/api/v1"
```

### Certificate Fingerprint

Production: Extract from client certificate
Development: Static fingerprint

```swift
self.certificateFingerprint = "development-cert-fingerprint"
```

### WebSocket URL

Update in `WebSocketClient.swift`:

```swift
let url = URL(string: "wss://api.moria.example.com/ws")
```

## Security Considerations

### Data Storage

- **Tokens**: Stored in iOS Keychain with `kSecAttrAccessibleAfterFirstUnlock`
- **Sensitive Data**: Never stored in UserDefaults or plain files
- **Encryption**: All API communication over HTTPS/WSS

### Certificate Pinning

TODO: Implement certificate pinning in production:

```swift
let config = URLSessionConfiguration.default
config.tlsMinimumSupportedProtocolVersion = .TLSv13
// Add certificate pinning configuration
```

### E2EE Implementation

**Note**: Current implementation uses placeholder encryption. Production must implement:

1. Signal Protocol for messaging
2. Key exchange and management
3. Forward secrecy
4. Perfect forward secrecy (PFS)

### Security Best Practices

1. **Never Log Sensitive Data**: No tokens, passwords, or decrypted content in logs
2. **Clear Memory**: Zero out sensitive data after use
3. **Background Protection**: Hide sensitive content when app enters background
4. **Biometric Lock**: Implement Face ID/Touch ID for app access
5. **Screenshot Prevention**: Disable screenshots for sensitive views
6. **SSL Pinning**: Implement in production

## API Integration

All API endpoints from backend are implemented:

### Authentication
- `POST /auth/login` - Certificate-based login
- `POST /auth/refresh` - Token refresh
- `POST /auth/logout` - Session termination
- `GET /auth/verify` - Token verification

### Messages
- `POST /messages` - Send encrypted message
- `GET /messages/conversations/{id}` - Get conversation messages
- `GET /messages/undelivered` - Undelivered messages
- `PUT /messages/{id}/delivered` - Mark delivered
- `PUT /messages/{id}/read` - Mark read
- `DELETE /messages/{id}` - Delete message

### Files
- `POST /files` - Upload file metadata
- `GET /files` - List files
- `POST /files/{id}/share` - Share file
- `GET /files/shared` - Get shared files
- `GET /files/{id}/versions` - File versions
- `POST /files/upload/start` - Start chunked upload
- `POST /files/upload/{id}/chunk` - Upload chunk
- `POST /files/upload/{id}/complete` - Complete upload

### Vault
- `POST /vault` - Create vault
- `GET /vault` - Get vault
- `PUT /vault` - Update vault
- `DELETE /vault` - Delete vault
- `POST /passwords/generate` - Generate password
- `POST /passwords/strength` - Check strength
- `POST /breach/check` - Check breach
- `GET /breach/alerts` - Breach alerts

### Security
- `GET /sessions` - List sessions
- `DELETE /sessions/{id}` - Revoke session
- `POST /sessions/revoke-others` - Revoke other sessions
- `GET /audit` - Query audit logs
- `GET /security/events` - Security events
- `GET /security/alerts` - Security alerts
- `PUT /presence` - Update presence
- `GET /notifications` - Get notifications

### MFA
- `POST /mfa/totp/setup` - TOTP setup
- `POST /mfa/totp/enable` - Enable TOTP
- `POST /mfa/verify` - Verify code
- `GET /mfa/methods` - List methods
- `POST /mfa/backup-codes` - Generate backup codes

## Development

### Requirements

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Setup

1. Clone repository
2. Open `moria.xcodeproj`
3. Update backend URL in `APIClient.swift`
4. Build and run

### Testing

1. Start backend server: `./bin/moria-server`
2. Run iOS app in simulator
3. Login with development fingerprint
4. Test features

### Code Style

- SwiftUI for all UI
- Async/await for networking
- Combine for reactive state
- MVVM architecture
- Protocol-oriented design

## Production Checklist

- [ ] Implement real Signal Protocol E2EE
- [ ] Add certificate pinning
- [ ] Implement biometric authentication
- [ ] Add screenshot prevention
- [ ] Implement proper key management
- [ ] Add background data protection
- [ ] Enable App Transport Security
- [ ] Implement secure enclave usage
- [ ] Add anti-tampering detection
- [ ] Perform security audit
- [ ] Add crash reporting (non-PII)
- [ ] Implement analytics (privacy-focused)
- [ ] Add proper error handling
- [ ] Implement offline support
- [ ] Add unit tests
- [ ] Add UI tests
- [ ] Perform penetration testing

## UI/UX Design Philosophy

**Military Command Center Aesthetic**:

- Minimal, functional design
- Monospace typography for technical feel
- Dark theme optimized for low-light operations
- Tactical green accents for secure/encrypted indicators
- Clear status indicators (online, secure, encrypted)
- No unnecessary animations or flourishes
- Information density appropriate for professional use
- Clear hierarchy and navigation
- Accessibility via color contrast and type size

**Inspired By**:
- X.com (formerly Twitter) - Clean, efficient layout
- Grok - Technical, minimal aesthetic
- Military tactical displays
- Command and control interfaces
- Signal - Security-first approach

## License

Proprietary - Defense and Government Contractors Only

Copyright © 2025 Moria Security Hub. All rights reserved.

---

**MORIA** - Military-Grade Security for Critical Operations

**ZERO TRUST • END-TO-END • FedRAMP READY**

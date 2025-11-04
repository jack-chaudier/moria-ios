//
//  WebSocketClient.swift
//  moria
//
//  Real-time WebSocket client for notifications, presence, and typing
//

import Foundation
import Combine

enum WebSocketMessageType: String, Codable {
    case notification
    case presence
    case typing
    case message
    case ping
    case pong
}

struct WebSocketMessage: Codable {
    let type: WebSocketMessageType
    let data: AnyCodable?
    let timestamp: Date
}

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}

final class WebSocketClient: NSObject, ObservableObject {
    static let shared = WebSocketClient()

    @Published var isConnected: Bool = false
    @Published var connectionState: URLSessionWebSocketTask.State = .suspended

    // Message publishers
    let notificationReceived = PassthroughSubject<[String: Any], Never>()
    let presenceUpdate = PassthroughSubject<[String: Any], Never>()
    let typingUpdate = PassthroughSubject<[String: Any], Never>()
    let messageReceived = PassthroughSubject<[String: Any], Never>()

    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var pingTimer: Timer?
    private var reconnectTimer: Timer?
    private var shouldReconnect = true

    private override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    // MARK: - Connection Management

    func connect(accessToken: String) {
        guard let url = URL(string: "wss://moria-backend.duckdns.org/api/v1/ws") else {
            print("[FAIL] Invalid WebSocket URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        // Add required WebSocket headers
        request.timeoutInterval = 10

        print("[INFO] Connecting to WebSocket: \(url.absoluteString)")
        print("[INFO] Authorization: Bearer \(accessToken.prefix(20))...")

        webSocketTask = session?.webSocketTask(with: request)
        webSocketTask?.resume()

        receiveMessage()
        startPingTimer()

        isConnected = true
    }

    func disconnect() {
        shouldReconnect = false
        stopPingTimer()
        stopReconnectTimer()

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil

        isConnected = false
    }

    private func reconnect() {
        guard shouldReconnect else { return }

        disconnect()

        // Try to reconnect with stored token
        if let token = APIClient.shared.accessToken {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.connect(accessToken: token)
            }
        }
    }

    // MARK: - Message Handling

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                self.handleMessage(message)
                // Continue receiving
                self.receiveMessage()

            case .failure(let error):
                print("WebSocket receive error: \(error)")
                self.handleDisconnection()
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            guard let data = text.data(using: .utf8) else { return }
            parseMessage(data)

        case .data(let data):
            parseMessage(data)

        @unknown default:
            break
        }
    }

    private func parseMessage(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let message = try decoder.decode(WebSocketMessage.self, from: data)

            // Extract data dictionary
            guard let dataDict = message.data?.value as? [String: Any] else {
                print("[WARN] WebSocket message has no data payload")
                return
            }

            // Route to appropriate publisher
            DispatchQueue.main.async { [weak self] in
                switch message.type {
                case .notification:
                    print("[INFO] Received notification: \(dataDict)")
                    self?.notificationReceived.send(dataDict)
                case .presence:
                    print("[INFO] Presence update: \(dataDict)")
                    self?.presenceUpdate.send(dataDict)
                case .typing:
                    print("[INFO] Typing indicator: \(dataDict)")
                    self?.typingUpdate.send(dataDict)
                case .message:
                    print("[INFO] New message received via WebSocket")
                    self?.messageReceived.send(dataDict)
                case .pong:
                    // Received pong response
                    print("[INFO] Received pong from server")
                    break
                case .ping:
                    // Respond to server ping
                    print("[INFO] Received ping, sending pong")
                    self?.sendPong()
                }
            }
        } catch {
            print("[FAIL] Failed to parse WebSocket message: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("[FAIL] Raw message: \(jsonString)")
            }
        }
    }

    private func handleDisconnection() {
        isConnected = false
        stopPingTimer()

        if shouldReconnect {
            startReconnectTimer()
        }
    }

    // MARK: - Sending Messages

    func send(type: WebSocketMessageType, data: [String: Any]? = nil) {
        let message = [
            "type": type.rawValue,
            "data": data ?? [:],
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ] as [String : Any]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: message),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }

        let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)
        webSocketTask?.send(wsMessage) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            }
        }
    }

    private func sendPing() {
        send(type: .ping)
    }

    private func sendPong() {
        send(type: .pong)
    }

    // MARK: - Ping/Pong Timer

    private func startPingTimer() {
        stopPingTimer()

        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }

    private func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    private func startReconnectTimer() {
        stopReconnectTimer()

        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            self?.reconnect()
        }
    }

    private func stopReconnectTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }

    deinit {
        disconnect()
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("[PASS] WebSocket connected successfully")
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = true
            self?.connectionState = .running
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let reasonString = reason.flatMap { String(data: $0, encoding: .utf8) } ?? "No reason"
        print("[WARN] WebSocket closed: code=\(closeCode.rawValue), reason=\(reasonString)")
        DispatchQueue.main.async { [weak self] in
            self?.handleDisconnection()
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("[FAIL] WebSocket task failed: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("[FAIL] Error domain: \(nsError.domain), code: \(nsError.code)")
                print("[FAIL] Error userInfo: \(nsError.userInfo)")
            }
        }
    }
}

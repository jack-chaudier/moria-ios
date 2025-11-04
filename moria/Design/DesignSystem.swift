//
//  DesignSystem.swift
//  moria
//
//  Military-grade minimal design system with monospace aesthetics
//

import SwiftUI

// MARK: - Colors

extension Color {
    // Military Dark Theme - inspired by tactical displays
    static let moriaBackground = Color(hex: "#0a0a0a")
    static let moriaSurface = Color(hex: "#111111")
    static let moriaCard = Color(hex: "#1a1a1a")
    static let moriaBorder = Color(hex: "#2a2a2a")

    // Primary - Tactical Green
    static let moriaPrimary = Color(hex: "#00ff41")
    static let moriaPrimaryDim = Color(hex: "#00cc34")

    // Accent Colors
    static let moriaSecondary = Color(hex: "#00d4ff")
    static let moriaWarning = Color(hex: "#ffaa00")
    static let moriaDanger = Color(hex: "#ff0055")
    static let moriaSuccess = Color(hex: "#00ff88")

    // Text Colors
    static let moriaText = Color(hex: "#e0e0e0")
    static let moriaTextSecondary = Color(hex: "#808080")
    static let moriaTextTertiary = Color(hex: "#505050")

    // Status Colors
    static let moriaOnline = Color(hex: "#00ff88")
    static let moriaAway = Color(hex: "#ffaa00")
    static let moriaBusy = Color(hex: "#ff0055")
    static let moriaOffline = Color(hex: "#505050")

    // Security Levels
    static let moriaClassified = Color(hex: "#ff0055")
    static let moriaSecret = Color(hex: "#ff8800")
    static let moriaConfidential = Color(hex: "#ffaa00")
    static let moriaUnclassified = Color(hex: "#00ff88")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography

struct MoriaFont {
    // Monospace fonts for military/tactical aesthetic
    static let system = "Menlo"
    static let systemBold = "Menlo-Bold"

    // Size scale
    static let title1 = Font.custom(system, size: 28).weight(.bold)
    static let title2 = Font.custom(system, size: 22).weight(.bold)
    static let title3 = Font.custom(system, size: 18).weight(.semibold)

    static let headline = Font.custom(system, size: 16).weight(.semibold)
    static let body = Font.custom(system, size: 14)
    static let bodyBold = Font.custom(systemBold, size: 14)
    static let callout = Font.custom(system, size: 13)
    static let caption = Font.custom(system, size: 12)
    static let caption2 = Font.custom(system, size: 11)
}

// MARK: - Spacing

struct MoriaSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Border Radius

struct MoriaRadius {
    static let sm: CGFloat = 4
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
}

// MARK: - Custom View Modifiers

struct MoriaCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.moriaCard)
            .cornerRadius(MoriaRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: MoriaRadius.md)
                    .stroke(Color.moriaBorder, lineWidth: 1)
            )
    }
}

struct MoriaButtonStyle: ButtonStyle {
    enum Style {
        case primary
        case secondary
        case danger
    }

    let style: Style

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(MoriaFont.bodyBold)
            .foregroundColor(.moriaBackground)
            .padding(.horizontal, MoriaSpacing.md)
            .padding(.vertical, MoriaSpacing.sm)
            .background(backgroundColor(configuration: configuration))
            .cornerRadius(MoriaRadius.sm)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }

    private func backgroundColor(configuration: Configuration) -> Color {
        switch style {
        case .primary:
            return .moriaPrimary
        case .secondary:
            return .moriaSecondary
        case .danger:
            return .moriaDanger
        }
    }
}

struct MoriaTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(MoriaFont.body)
            .foregroundColor(.moriaText)
            .padding(MoriaSpacing.sm)
            .background(Color.moriaSurface)
            .cornerRadius(MoriaRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: MoriaRadius.sm)
                    .stroke(Color.moriaBorder, lineWidth: 1)
            )
    }
}

// MARK: - View Extensions

extension View {
    func moriaCard() -> some View {
        modifier(MoriaCardModifier())
    }

    func moriaPrimaryButton() -> some View {
        buttonStyle(MoriaButtonStyle(style: .primary))
    }

    func moriaSecondaryButton() -> some View {
        buttonStyle(MoriaButtonStyle(style: .secondary))
    }

    func moriaDangerButton() -> some View {
        buttonStyle(MoriaButtonStyle(style: .danger))
    }
}

// MARK: - Custom Components

struct MoriaDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.moriaBorder)
            .frame(height: 1)
    }
}

struct MoriaStatusBadge: View {
    let status: PresenceStatus

    var body: some View {
        HStack(spacing: MoriaSpacing.xs) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(status.rawValue.uppercased())
                .font(MoriaFont.caption2)
                .foregroundColor(.moriaTextSecondary)
        }
        .padding(.horizontal, MoriaSpacing.xs)
        .padding(.vertical, 2)
        .background(Color.moriaSurface)
        .cornerRadius(MoriaRadius.sm)
    }

    private var statusColor: Color {
        switch status {
        case .online:
            return .moriaOnline
        case .away:
            return .moriaAway
        case .busy:
            return .moriaBusy
        case .offline:
            return .moriaOffline
        }
    }
}

struct MoriaSecurityBadge: View {
    let severity: SecuritySeverity

    var body: some View {
        Text(severity.rawValue.uppercased())
            .font(MoriaFont.caption2)
            .foregroundColor(.moriaBackground)
            .padding(.horizontal, MoriaSpacing.xs)
            .padding(.vertical, 2)
            .background(severityColor)
            .cornerRadius(MoriaRadius.sm)
    }

    private var severityColor: Color {
        switch severity {
        case .low:
            return .moriaSuccess
        case .medium:
            return .moriaWarning
        case .high:
            return .moriaDanger
        case .critical:
            return .moriaClassified
        }
    }
}

struct MoriaLoadingView: View {
    var body: some View {
        VStack(spacing: MoriaSpacing.md) {
            ProgressView()
                .tint(.moriaPrimary)

            Text("LOADING...")
                .font(MoriaFont.caption)
                .foregroundColor(.moriaTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.moriaBackground)
    }
}

struct MoriaErrorView: View {
    let error: String
    let retry: (() -> Void)?

    var body: some View {
        VStack(spacing: MoriaSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.moriaDanger)

            Text("ERROR")
                .font(MoriaFont.title3)
                .foregroundColor(.moriaText)

            Text(error)
                .font(MoriaFont.body)
                .foregroundColor(.moriaTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MoriaSpacing.xl)

            if let retry = retry {
                Button("RETRY") {
                    retry()
                }
                .moriaPrimaryButton()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.moriaBackground)
    }
}

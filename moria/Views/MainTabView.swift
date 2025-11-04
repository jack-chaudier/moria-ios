//
//  MainTabView.swift
//  moria
//
//  Main navigation interface
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var authViewModel = AuthViewModel()

    enum Tab {
        case messages
        case files
        case vault
        case security
    }

    @State private var selectedTab: Tab = .messages

    var body: some View {
        ZStack {
            Color.moriaBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Status Bar
                statusBar

                // Content
                contentView
                    .frame(maxHeight: .infinity)

                // Bottom Navigation
                navigationBar
            }
        }
        .preferredColorScheme(.dark)
    }

    private var statusBar: some View {
        HStack {
            // Logo
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 20))
                .foregroundColor(.moriaPrimary)

            Text("MORIA")
                .font(MoriaFont.headline)
                .foregroundColor(.moriaText)
                .tracking(2)

            Spacer()

            // Status indicator
            HStack(spacing: MoriaSpacing.xs) {
                Circle()
                    .fill(Color.moriaOnline)
                    .frame(width: 6, height: 6)

                Text("SECURE")
                    .font(MoriaFont.caption2)
                    .foregroundColor(.moriaTextSecondary)
            }

            // Profile/Logout
            Button {
                authViewModel.logout()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18))
                    .foregroundColor(.moriaTextSecondary)
            }
        }
        .padding(.horizontal, MoriaSpacing.md)
        .padding(.vertical, MoriaSpacing.sm)
        .background(Color.moriaSurface)
        .overlay(
            Rectangle()
                .fill(Color.moriaBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case .messages:
            MessagesView()
        case .files:
            FilesView()
        case .vault:
            VaultView()
        case .security:
            SecurityView()
        }
    }

    private var navigationBar: some View {
        HStack(spacing: 0) {
            tabButton(
                icon: "message.fill",
                title: "MESSAGES",
                tab: .messages
            )

            tabButton(
                icon: "folder.fill",
                title: "FILES",
                tab: .files
            )

            tabButton(
                icon: "lock.fill",
                title: "VAULT",
                tab: .vault
            )

            tabButton(
                icon: "shield.fill",
                title: "SECURITY",
                tab: .security
            )
        }
        .background(Color.moriaSurface)
        .overlay(
            Rectangle()
                .fill(Color.moriaBorder)
                .frame(height: 1),
            alignment: .top
        )
    }

    private func tabButton(icon: String, title: String, tab: Tab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: MoriaSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 20))

                Text(title)
                    .font(MoriaFont.caption2)
                    .tracking(1)
            }
            .foregroundColor(selectedTab == tab ? .moriaPrimary : .moriaTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, MoriaSpacing.sm)
        }
    }
}

// MARK: - Placeholder Views

struct FilesView: View {
    var body: some View {
        placeholderView(
            icon: "folder.fill",
            title: "FILES",
            subtitle: "Secure file sharing"
        )
    }
}

struct VaultView: View {
    var body: some View {
        placeholderView(
            icon: "lock.fill",
            title: "VAULT",
            subtitle: "Password management"
        )
    }
}

struct SecurityView: View {
    var body: some View {
        placeholderView(
            icon: "shield.fill",
            title: "SECURITY",
            subtitle: "Audit logs & alerts"
        )
    }
}

private func placeholderView(icon: String, title: String, subtitle: String) -> some View {
    VStack(spacing: MoriaSpacing.md) {
        Image(systemName: icon)
            .font(.system(size: 48))
            .foregroundColor(.moriaPrimary)

        Text(title)
            .font(MoriaFont.title2)
            .foregroundColor(.moriaText)

        Text(subtitle)
            .font(MoriaFont.body)
            .foregroundColor(.moriaTextSecondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.moriaBackground)
}

#Preview {
    MainTabView()
}

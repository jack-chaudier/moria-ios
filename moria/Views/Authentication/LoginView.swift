//
//  LoginView.swift
//  moria
//
//  Military-grade login interface
//

import SwiftUI

struct LoginView: View {
    @StateObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            Color.moriaBackground.ignoresSafeArea()

            VStack(spacing: MoriaSpacing.xl) {
                Spacer()

                // Logo and Title
                VStack(spacing: MoriaSpacing.md) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 64))
                        .foregroundColor(.moriaPrimary)

                    Text("MORIA")
                        .font(MoriaFont.title1)
                        .foregroundColor(.moriaText)
                        .tracking(8)

                    Text("SECURITY HUB")
                        .font(MoriaFont.caption)
                        .foregroundColor(.moriaTextSecondary)
                        .tracking(4)

                    MoriaDivider()
                        .frame(width: 200)
                        .padding(.top, MoriaSpacing.sm)
                }

                Spacer()

                // Certificate Authentication Info
                VStack(spacing: MoriaSpacing.md) {
                    HStack(spacing: MoriaSpacing.sm) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.moriaPrimary)

                        Text("CERTIFICATE AUTHENTICATED")
                            .font(MoriaFont.caption)
                            .foregroundColor(.moriaTextSecondary)
                    }

                    // Device Info
                    VStack(spacing: MoriaSpacing.xs) {
                        infoRow(label: "DEVICE", value: UIDevice.current.model.uppercased())
                        infoRow(label: "OS", value: "iOS \(UIDevice.current.systemVersion)")
                        infoRow(label: "ID", value: (UIDevice.current.identifierForVendor?.uuidString.prefix(8) ?? "UNKNOWN").uppercased())
                    }
                    .padding(MoriaSpacing.md)
                    .moriaCard()
                }
                .padding(.horizontal, MoriaSpacing.xl)

                Spacer()

                // Login Button
                VStack(spacing: MoriaSpacing.md) {
                    if authViewModel.isLoading {
                        HStack(spacing: MoriaSpacing.sm) {
                            ProgressView()
                                .tint(.moriaPrimary)
                            Text("AUTHENTICATING...")
                                .font(MoriaFont.bodyBold)
                                .foregroundColor(.moriaTextSecondary)
                        }
                        .frame(height: 44)
                    } else {
                        Button {
                            Task {
                                await authViewModel.login()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "lock.shield")
                                Text("SECURE LOGIN")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                        }
                        .moriaPrimaryButton()
                    }

                    // Error Message
                    if let error = authViewModel.error {
                        Text(error.uppercased())
                            .font(MoriaFont.caption)
                            .foregroundColor(.moriaDanger)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, MoriaSpacing.md)
                    }
                }
                .padding(.horizontal, MoriaSpacing.xl)

                Spacer()

                // Footer
                VStack(spacing: MoriaSpacing.xs) {
                    Text("MILITARY-GRADE ENCRYPTION")
                        .font(MoriaFont.caption2)
                        .foregroundColor(.moriaTextTertiary)

                    Text("ZERO TRUST • END-TO-END • FedRAMP READY")
                        .font(MoriaFont.caption2)
                        .foregroundColor(.moriaTextTertiary)
                        .tracking(1)
                }
                .padding(.bottom, MoriaSpacing.xl)
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(MoriaFont.caption2)
                .foregroundColor(.moriaTextSecondary)

            Spacer()

            Text(value)
                .font(MoriaFont.caption)
                .foregroundColor(.moriaPrimary)
        }
    }
}

#Preview {
    LoginView(authViewModel: AuthViewModel())
}

//
//  NewConversationView.swift
//  moria
//
//  Create new secure conversation
//

import SwiftUI

struct NewConversationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var recipientUsername: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moriaBackground.ignoresSafeArea()

                VStack(spacing: MoriaSpacing.lg) {
                    // Header
                    VStack(spacing: MoriaSpacing.sm) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.moriaPrimary)

                        Text("NEW SECURE CONVERSATION")
                            .font(MoriaFont.title2)
                            .foregroundColor(.moriaText)

                        Text("Start an end-to-end encrypted chat")
                            .font(MoriaFont.caption)
                            .foregroundColor(.moriaTextSecondary)
                    }
                    .padding(.top, MoriaSpacing.xxl)

                    // Input Fields
                    VStack(alignment: .leading, spacing: MoriaSpacing.md) {
                        Text("RECIPIENT")
                            .font(MoriaFont.caption)
                            .foregroundColor(.moriaTextSecondary)

                        TextField("Username or User ID", text: $recipientUsername)
                            .textFieldStyle(.plain)
                            .font(MoriaFont.body)
                            .foregroundColor(.moriaText)
                            .padding(MoriaSpacing.sm)
                            .background(Color.moriaSurface)
                            .cornerRadius(MoriaRadius.md)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, MoriaSpacing.md)

                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(MoriaFont.caption)
                            .foregroundColor(.moriaDanger)
                            .padding(.horizontal, MoriaSpacing.md)
                    }

                    Spacer()

                    // Start Button
                    Button {
                        startConversation()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.moriaBackground)
                            }
                            Text("START CONVERSATION")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                    }
                    .moriaPrimaryButton()
                    .disabled(recipientUsername.isEmpty || isLoading)
                    .padding(.horizontal, MoriaSpacing.md)
                    .padding(.bottom, MoriaSpacing.lg)
                }
            }
            .navigationTitle("NEW MESSAGE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.moriaTextSecondary)
                }
            }
        }
    }

    private func startConversation() {
        // TODO: Implement conversation creation
        // This would typically:
        // 1. Look up user by username
        // 2. Create conversation if it doesn't exist
        // 3. Navigate to conversation detail
        isLoading = true
        errorMessage = nil

        Task {
            // Simulated delay
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            await MainActor.run {
                isLoading = false
                errorMessage = "[INFO] Conversation creation not yet implemented"
                // dismiss()
            }
        }
    }
}

#Preview {
    NewConversationView()
}

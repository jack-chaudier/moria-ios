//
//  NewGroupView.swift
//  moria
//
//  Create new group conversation
//

import SwiftUI

struct NewGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MessagesViewModel

    @State private var groupName: String = ""
    @State private var groupDescription: String = ""

    init(viewModel: MessagesViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moriaBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: MoriaSpacing.lg) {
                        // Header
                        VStack(spacing: MoriaSpacing.sm) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.moriaPrimary)

                            Text("CREATE GROUP")
                                .font(MoriaFont.title2)
                                .foregroundColor(.moriaText)

                            Text("Secure group messaging")
                                .font(MoriaFont.caption)
                                .foregroundColor(.moriaTextSecondary)
                        }
                        .padding(.top, MoriaSpacing.xxl)

                        // Input Fields
                        VStack(alignment: .leading, spacing: MoriaSpacing.md) {
                            // Group Name
                            VStack(alignment: .leading, spacing: MoriaSpacing.xs) {
                                Text("GROUP NAME")
                                    .font(MoriaFont.caption)
                                    .foregroundColor(.moriaTextSecondary)

                                TextField("Enter group name", text: $groupName)
                                    .textFieldStyle(.plain)
                                    .font(MoriaFont.body)
                                    .foregroundColor(.moriaText)
                                    .padding(MoriaSpacing.sm)
                                    .background(Color.moriaSurface)
                                    .cornerRadius(MoriaRadius.md)
                            }

                            // Group Description
                            VStack(alignment: .leading, spacing: MoriaSpacing.xs) {
                                Text("DESCRIPTION (OPTIONAL)")
                                    .font(MoriaFont.caption)
                                    .foregroundColor(.moriaTextSecondary)

                                TextField("Enter description", text: $groupDescription, axis: .vertical)
                                    .textFieldStyle(.plain)
                                    .font(MoriaFont.body)
                                    .foregroundColor(.moriaText)
                                    .padding(MoriaSpacing.sm)
                                    .background(Color.moriaSurface)
                                    .cornerRadius(MoriaRadius.md)
                                    .lineLimit(3...5)
                            }
                        }
                        .padding(.horizontal, MoriaSpacing.md)

                        // Error Message
                        if let error = viewModel.error {
                            Text(error)
                                .font(MoriaFont.caption)
                                .foregroundColor(.moriaDanger)
                                .padding(.horizontal, MoriaSpacing.md)
                        }

                        Spacer()
                    }
                }

                // Create Button (floating at bottom)
                VStack {
                    Spacer()

                    Button {
                        createGroup()
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.moriaBackground)
                            }
                            Text("CREATE GROUP")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                    }
                    .moriaPrimaryButton()
                    .disabled(groupName.isEmpty || viewModel.isLoading)
                    .padding(.horizontal, MoriaSpacing.md)
                    .padding(.bottom, MoriaSpacing.lg)
                }
            }
            .navigationTitle("NEW GROUP")
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

    private func createGroup() {
        Task {
            await viewModel.createGroup(
                name: groupName,
                description: groupDescription.isEmpty ? nil : groupDescription
            )

            // Close sheet on success
            if viewModel.error == nil {
                dismiss()
            }
        }
    }
}

#Preview {
    NewGroupView(viewModel: MessagesViewModel())
}

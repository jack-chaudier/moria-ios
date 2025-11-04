//
//  ContentView.swift
//  moria
//
//  Main app coordinator view
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showConnectionTest = false

    var body: some View {
        ZStack {
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView()
                } else {
                    LoginView(authViewModel: authViewModel)
                }
            }
            .preferredColorScheme(.dark)

            // Connection Test Button (floating)
            if !authViewModel.isAuthenticated {
                VStack {
                    HStack {
                        Spacer()

                        Button {
                            showConnectionTest = true
                        } label: {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.system(size: 16))
                                .foregroundColor(.moriaBackground)
                                .padding(12)
                                .background(Color.moriaPrimary)
                                .clipShape(Circle())
                        }
                        .padding()
                    }

                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showConnectionTest) {
            ConnectionTestView()
        }
    }
}

#Preview {
    ContentView()
}

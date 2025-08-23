//
//  VerifyEmailView.swift
//  Flowt
//
//  Created by Wiktor Drab on 23/08/2025.
//

import SwiftUI

struct VerifyEmailView: View {
    @StateObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Please verify your email")
                .font(.title2)
                .padding()
            
            Text("We sent a verification link to your email. Please confirm to continue.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Resend verification email") {
                Task { await viewModel.resendVerificationEmail() }
            }
            .buttonStyle(.bordered)
            
            Button("I verified my email") {
                viewModel.refreshSession()
            }
            .buttonStyle(.borderedProminent)
            
            Button(role: .destructive) {
                viewModel.signOut()
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
            
            if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            }
        }
        .padding()
    }
}


#Preview {
    let appState = AppState()
    let viewModel = AuthViewModel(appState: appState)
    VerifyEmailView(viewModel: viewModel)
        .environmentObject(appState)
}

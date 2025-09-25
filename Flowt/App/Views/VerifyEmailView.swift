//
//  VerifyEmailView.swift
//  Flowt
//
//  Created by Wiktor Drab on 23/08/2025.
//

import SwiftUI

struct VerifyEmailView: View {
    @StateObject var viewModel: VerifyEmailViewModel
    
    var body: some View {
        ZStack {
            BackgroundView(withLogo: false, hasBottomBar: false)
            
            VStack(spacing: 30) {
                Image("FlowtLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .shadow(radius: 10)
                
                Text("Verify your email")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                
                Text("We sent a verification link to your email.\nPlease confirm to continue.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal)
                
                Button("Resend verification email") {
                    Task { await viewModel.resendVerificationEmail() }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.15))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.top, 10)
                
                Button(role: .destructive) {
                    viewModel.signOut()
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .padding(.top, 15)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.yellow)
                        .font(.callout)
                        .padding(.top, 5)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 30)
        }
    }
}


#Preview {
    let appState = AppState()
    let viewModel = VerifyEmailViewModel(appState: appState, authService: AuthService())
    VerifyEmailView(viewModel: viewModel)
        .environmentObject(appState)
}

//
//  SignInView.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/08/2025.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @StateObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Flowt")
                .font(.largeTitle)
                .bold()
            
            // Email login
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Button("Sign In") {
                    Task { await viewModel.signIn(email: email, password: password) }
                }
                Button("Sign Up") {
                    Task { await viewModel.signUp(email: email, password: password) }
                }
            }
            
            // Apple login - (my tutaj tylko przekazujemy funkcje, SignInWithAppleButton odpali je w odpowiednim momencie)
            SignInWithAppleButton(onRequest: viewModel.handleAppleRequest, onCompletion: viewModel.handleAppleCompletion)
            .signInWithAppleButtonStyle(.black)
            .frame(height: 45)
            .padding(.top, 30)
            
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
    SignInView(viewModel: viewModel)
        .environmentObject(appState)
}

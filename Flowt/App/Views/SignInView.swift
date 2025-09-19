//
//  SignInView.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/08/2025.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    enum Field { case email, password }
    
    @StateObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focusedField: Field? // info w jakim polu tekstowym user ma klawiature (email czy password)
    
    var body: some View {
        ZStack {
            BackgroundView(withLogo: false, hasBottomBar: false)
                .onTapGesture { focusedField = nil } // jak klikamy gdzies poza TextField to ustawia sie na nil
            
            VStack(spacing: 30) {
                Image("FlowtLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .shadow(radius: 10)
                
                VStack(spacing: 16) {
                    inputField(systemIcon: "envelope", placeholder: "Email", text: $viewModel.email, focused: $focusedField, field: .email)
                    inputField(systemIcon: "lock", placeholder: "Password", text: $viewModel.password, isSecure: true, focused: $focusedField, field: .password)
                }
                
                Button {
                    Task { await viewModel.submit() }
                } label: {
                    Text(viewModel.isRegistering ? "Sign Up" : "Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.headline)
                        .foregroundColor(.white)
                        .background(viewModel.canSubmit ? Color.black.opacity(0.85) : Color.gray.opacity(0.5))
                        .cornerRadius(12)
                }
                .disabled(!viewModel.canSubmit)
                
                SignInWithAppleButton(onRequest: viewModel.handleAppleRequest, onCompletion: viewModel.handleAppleCompletion)
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(12)
                .padding(.top, 10)
                
                HStack {
                    Text(viewModel.isRegistering ? "Already have an account?" : "Don’t have an account?")
                        .foregroundColor(.white.opacity(0.8))
                    
                    Button(viewModel.isRegistering ? "Sign In" : "Sign Up") { viewModel.toggleMode() }
                    .fontWeight(.semibold)
                }
                .padding(.top, 10)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.yellow)
                        .font(.footnote)
                        .padding(.top, 5)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 30)
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView("Signing in...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
    }
    
    @ViewBuilder
    private func inputField(systemIcon: String, placeholder: String, text: Binding<String>, isSecure: Bool = false, focused: FocusState<Field?>.Binding, field: Field) -> some View {
        HStack {
            Image(systemName: systemIcon)
                .foregroundColor(.gray)
            if isSecure {
                SecureField(placeholder, text: text)
                    .focused(focused, equals: field)
            } else {
                TextField(placeholder, text: text)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled()
                    .focused(focused, equals: field)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.25).opacity(0.75) : .white)
        .cornerRadius(12)
    }
}

#Preview {
    let appState = AppState()
    let viewModel = AuthViewModel(appState: appState)
    SignInView(viewModel: viewModel)
        .environmentObject(appState)
}

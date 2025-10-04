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
    @State private var showForgotPasswordSheet = false
    @State private var resetEmail: String = ""
    @FocusState private var focusedField: Bool
    @AppStorage("hasAcceptedTerms") private var hasAccepted: Bool = false
    
    var body: some View {
        ZStack {
            BackgroundView(withLogo: false, hasBottomBar: false)
                .onTapGesture { focusedField = false }
                .ignoresSafeArea()
            
            if !hasAccepted {
                TermsAgreementView(infoVM: InfoViewModel(), hasAccepted: $hasAccepted)
                    .transition(.opacity)
            } else {
                VStack(spacing: 15) {
                    headerPanel
                    logoPanel
                    formPanel
                    actionsPanel
                    forgotPasswordRow
                    modeSwitcher
                    if let error = viewModel.errorMessage { errorBanner(error) }
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
                
                if viewModel.isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView("Signing in...")
                        .padding(.horizontal, 18).padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)
                }
            }
        }
        .sheet(isPresented: $showForgotPasswordSheet) { forgotPasswordSheet }
    }
    
    // MARK: - Panels
    
    private var headerPanel: some View {
        EdgeLitContainer {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(
                        title: viewModel.isRegistering ? "Create Account" : "Welcome Back",
                        subtitle: viewModel.isRegistering ? "Sync scores & compete" : "Sign in to continue"
                    )
                }
                Spacer()
            }
            .overlay(alignment: .topTrailing) {
                FlowDecoration()
                    .opacity(0.15)
                    .padding(.trailing, 8)
                    .padding(.bottom, 6)
            }
        }
    }
    
    private var logoPanel: some View {
        Image("FlowtLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 250, height: 250)
            .shadow(radius: 10)
    }
    
    private var formPanel: some View {
        EdgeLitContainer {
            VStack(spacing: 12) {
                GlassField(systemIcon: "envelope", placeholder: "Email", text: $viewModel.email, isSecure: false, submitLabel: .next, focused: $focusedField, field: true, onSubmit: { focusedField = true })
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)

                GlassField(systemIcon: "lock", placeholder: "Password", text: $viewModel.password, isSecure: true, submitLabel: .go, focused: $focusedField, field: true, onSubmit: { Task { await viewModel.submit() } })
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            }
        }
    }
    
    private var actionsPanel: some View {
        VStack(spacing: 12) {
            AnimatedGradientButton(
                title: viewModel.isRegistering ? "Sign Up" : "Sign In",
                symbol: viewModel.isRegistering ? "person.badge.plus" : "arrow.right.circle.fill",
                gradientColors: animatedGradientButtonColors
            ) { Task { await viewModel.submit() } }
            .frame(height: 52)
            .disabled(!viewModel.canSubmit)
            .opacity(viewModel.canSubmit ? 1 : 0.5)
            
            SignInWithAppleButton(onRequest: viewModel.handleAppleRequest, onCompletion: viewModel.handleAppleCompletion)
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(LinearGradient(colors: [.cyan, .teal], startPoint: .leading, endPoint: .trailing), lineWidth: 1)
            )
            .padding(.top, 28)
        }
    }
    
    private var forgotPasswordRow: some View {
        Button {
            resetEmail = viewModel.email
            showForgotPasswordSheet = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "questionmark.circle")
                Text("Forgot password?")
                    .underline()
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white.opacity(0.85))
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Capsule().fill(Color.white.opacity(0.05)))
            .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .padding(.top, 6)
    }

    
    private var modeSwitcher: some View {
        HStack(spacing: 8) {
            Text(viewModel.isRegistering ? "Already have an account?" : "Don’t have an account?")
                .foregroundStyle(.white.opacity(0.8))
                .font(.footnote)
            Button(viewModel.isRegistering ? "Sign In" : "Sign Up") {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { viewModel.toggleMode() }
            }
            .font(.footnote)
            .fontWeight(.semibold)
        }
        .padding(.top, 4)
    }
    
    private var forgotPasswordSheet: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.headline)
                .padding(.top, 12)
            
            GlassField(systemIcon: "envelope", placeholder: "Enter your email", text: $resetEmail, isSecure: false, submitLabel: .go, focused: $focusedField, field: true, onSubmit: {
                focusedField = false
                Task { await viewModel.resetPasswordWithEmail(resetEmail) }
                showForgotPasswordSheet = false
            })
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(.emailAddress)

            HStack {
                Button("Cancel") { showForgotPasswordSheet = false }
                .foregroundColor(.red)

                Spacer()

                Button("Send Link") {
                    Task { if !resetEmail.isEmpty { await viewModel.resetPasswordWithEmail(resetEmail) } }
                    showForgotPasswordSheet = false
                }
                .disabled(resetEmail.isEmpty)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .presentationDetents([.fraction(0.3)])
        .background(BackgroundView(withLogo: false, hasBottomBar: false))
    }
    
    @ViewBuilder
    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                .font(.system(size: 14, weight: .bold))
            Text(message)
                .font(.callout)
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.white.opacity(0.06)))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.white.opacity(0.12), lineWidth: 1))
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#Preview {
    let appState = AppState()
    let viewModel = AuthViewModel(appState: appState, authService: AuthService())
    SignInView(viewModel: viewModel)
        .environmentObject(appState)
}

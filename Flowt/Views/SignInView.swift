//
//  SignInView.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/08/2025.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    enum Field: Hashable { case email, password, sheet }
    
    @ObservedObject var authVM: AuthViewModel
    @State private var showForgotPasswordSheet = false
    @State private var resetEmail: String = ""
    @FocusState private var focusedField: Field?
    @AppStorage("hasAcceptedTerms") private var hasAccepted: Bool = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            BackgroundView(withLogo: false, hasBottomBar: false)
                .onTapGesture { focusedField = nil }
                .ignoresSafeArea()
            
            ZStack {
                if !hasAccepted {
                    TermsAgreementView(infoVM: InfoViewModel(), hasAccepted: $hasAccepted)
                        .transition(.opacity)
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            headerPanel
                            logoPanel
                            formPanel
                            actionsPanel
                            forgotPasswordRow
                            modeSwitcher
                            if let error = authVM.errorMessage {
                                banner(message: error, colors: [.yellow, .orange], symbol: "exclamationmark.triangle.fill")
                                    .accessibilityElement(children: .ignore)
                                    .accessibilityIdentifier("login_errorBanner")
                            }
                            else if let info = authVM.infoMessage {
                                banner(message: info, colors: [.cyan, .teal], symbol: "checkmark.seal.fill")
                                    .accessibilityElement(children: .ignore)
                                    .accessibilityIdentifier("login_infoBanner")
                            }
                            Spacer(minLength: 20)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 30)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .scrollDismissesKeyboard(.immediately)
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: hasAccepted)
            
            if authVM.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                ProgressView("Signing in...")
                    .padding(.horizontal, 18).padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)
                    .accessibilityIdentifier("signIn_progress")
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
                        title: authVM.isRegistering ? "Create Account" : "Welcome Back",
                        subtitle: authVM.isRegistering ? "Sync scores & compete" : "Sign in to continue"
                    )
                }
                Spacer()
            }
            .overlay(alignment: .topTrailing) {
                FlowDecoration()
                    .opacity(0.15)
                    .padding(.trailing, 8)
                    .padding(.bottom, 6)
                    .accessibilityHidden(true)
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
                GlassField(systemIcon: "envelope", placeholder: "Email", text: $authVM.email, isSecure: false, submitLabel: .next, focused: $focusedField, field: .email, onSubmit: { focusedField = .password })
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .accessibilityLabel("Email address")
                .accessibilityIdentifier("login_emailTextField")

                GlassField(systemIcon: "lock", placeholder: "Password", text: $authVM.password, isSecure: true, submitLabel: .go, focused: $focusedField, field: .password, onSubmit: { Task { await authVM.submit() } })
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Password")
                .accessibilityIdentifier("login_passwordSecureTextField")
            }
        }
    }
    
    private var actionsPanel: some View {
        VStack(spacing: 12) {
            AnimatedGradientButton(
                title: authVM.isRegistering ? "Sign Up" : "Sign In",
                symbol: authVM.isRegistering ? "person.badge.plus" : "arrow.right.circle.fill",
                gradientColors: animatedGradientButtonColors
            ) { Task { await authVM.submit() } }
            .frame(height: 52)
            .disabled(!authVM.canSubmit)
            .opacity(authVM.canSubmit ? 1 : 0.5)
            .accessibilityIdentifier("login_submitButton")
            
            SignInWithAppleButton(onRequest: authVM.handleAppleRequest, onCompletion: authVM.handleAppleCompletion)
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
            resetEmail = authVM.email
            showForgotPasswordSheet = true
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
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
        .accessibilityIdentifier("forgot_password_button")
    }

    
    private var modeSwitcher: some View {
        HStack(spacing: 8) {
            Text(authVM.isRegistering ? "Already have an account?" : "Don’t have an account?")
                .foregroundStyle(.white.opacity(0.8))
                .font(.footnote)
            Button(authVM.isRegistering ? "Sign In" : "Sign Up") {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { authVM.toggleMode() }
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
            .font(.footnote)
            .fontWeight(.semibold)
            .accessibilityIdentifier("auth_mode_switch_button")
        }
        .padding(.top, 4)
    }
    
    // MARK: Subviews
    private var forgotPasswordSheet: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.headline)
                .padding(.top, 12)
            
            GlassField(systemIcon: "envelope", placeholder: "Enter your email", text: $resetEmail, isSecure: false, submitLabel: .go, focused: $focusedField, field: .sheet, onSubmit: {
                focusedField = nil
                Task { await authVM.resetPasswordWithEmail(resetEmail) }
                showForgotPasswordSheet = false
            })
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(.emailAddress)
            .accessibilityLabel("Email address")
            .accessibilityIdentifier("forgot_sheet_email")

            HStack {
                Button("Cancel") {
                    showForgotPasswordSheet = false
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
                .foregroundColor(.red)
                .accessibilityIdentifier("forgot_sheet_cancel_button")

                Spacer()

                Button("Send Link") {
                    Task { if !resetEmail.isEmpty { await authVM.resetPasswordWithEmail(resetEmail) } }
                    showForgotPasswordSheet = false
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
                .disabled(resetEmail.isEmpty)
                .accessibilityIdentifier("forgot_send_link_button")
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .presentationDetents([.fraction(0.3)])
        .background(BackgroundView(withLogo: false, hasBottomBar: false))
    }
    
    @ViewBuilder
    private func banner(message: String, colors: [Color], symbol: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
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

#if DEBUG
#Preview {
    let appState = AppState()
    let viewModel = AuthViewModel(appState: appState, authService: AuthService())
    SignInView(authVM: viewModel)
        .environmentObject(appState)
}
#endif

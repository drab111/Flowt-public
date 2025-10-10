//
//  VerifyEmailView.swift
//  Flowt
//
//  Created by Wiktor Drab on 23/08/2025.
//

import SwiftUI

struct VerifyEmailView: View {
    @ObservedObject var verifyVM: VerifyEmailViewModel
    @Environment(\.openURL) private var openURL
    @State private var tipsOpen = false

    // MARK: - Body
    var body: some View {
        ZStack {
            BackgroundView(withLogo: false, hasBottomBar: false)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                headerPanel
                logoPanel
                actionsPanel
                troubleshootingPanel
                signOutPanel
                Spacer(minLength: 12)
            }
            .padding(.horizontal, 22)
            .padding(.top, 28)
        }
    }
    
    // MARK: - Panels
    private var headerPanel: some View {
        EdgeLitContainer {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: "Verify your email", subtitle: "Almost there")
                    
                    Divider()
                        .overlay(LinearGradient(colors: [.white.opacity(0.0), .white.opacity(0.25), .white.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
                        .padding(.vertical, 2)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Tap the link we sent to your inbox.")
                    }
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.75))
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
    
    private var actionsPanel: some View {
        EdgeLitContainer {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    ActionPill(title: "Open Mail", system: "envelope.open.fill") {
                        if let url = URL(string: "message://") { openURL(url) }
                    }
                    .accessibilityLabel("Open Mail")
                    .accessibilityHint("Opens the Mail app to find the verification email.")

                    ActionPill(title: "Resend email", system: "arrow.clockwise") {
                        Task { await verifyVM.resendVerificationEmail() }
                    }
                    .accessibilityLabel("Resend verification email")
                    .accessibilityHint("Sends a new verification link to your email address.")
                }

                if let error = verifyVM.errorMessage {
                    messageRow(system: "exclamationmark.triangle.fill", color: [.yellow, .orange], text: error)
                } else if let info = verifyVM.infoMessage {
                    messageRow(system: "checkmark.seal.fill", color: [.cyan, .teal], text: info)
                }
            }
        }
    }
    
    private var troubleshootingPanel: some View {
        EdgeLitContainer {
            DisclosureGroup(isExpanded: $tipsOpen) {
                VStack(alignment: .leading, spacing: 8) {
                    BulletRow("Check Spam/Junk and Promotions.")
                    BulletRow("Search inbox for “Flowt” or “verify”.")
                }
                .padding(.top, 6)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundStyle(LinearGradient(colors: [.cyan, .teal], startPoint: .leading, endPoint: .trailing))
                    Text("Didn’t get the email?")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }
            .tint(.white)
        }
    }
    
    private var signOutPanel: some View {
        Button(role: .destructive) { verifyVM.signOut() } label: {
            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.white.opacity(0.05)))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.white.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .padding(.top, 6)
    }

    // MARK: - Helpers
    private func messageRow(system: String, color: [Color], text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: system)
                .foregroundStyle(LinearGradient(colors: color, startPoint: .topLeading, endPoint: .bottomTrailing))
            Text(text)
        }
        .font(.callout)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 2)
    }
}

// MARK: - Subviews
private struct ActionPill: View {
    let title: String
    let system: String
    var action: () -> Void

    var body: some View {
        Button { action() } label: {
            HStack(spacing: 8) {
                Image(systemName: system)
                    .font(.system(size: 14, weight: .bold))
                Text(title)
                    .font(.footnote.weight(.semibold))
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(LinearGradient(colors: [.cyan, .teal], startPoint: .leading, endPoint: .trailing), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct BulletRow: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(.cyan)
                .frame(width: 6, height: 6)
            Text(text)
                .foregroundStyle(.white.opacity(0.9))
                .font(.footnote)
            Spacer(minLength: 0)
        }
    }
}

#if DEBUG
#Preview {
    let appState = AppState()
    let viewModel = VerifyEmailViewModel(appState: appState, authService: AuthService())
    VerifyEmailView(verifyVM: viewModel)
        .environmentObject(appState)
}
#endif

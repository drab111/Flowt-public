//
//  VerifyEmailView.swift
//  Flowt
//
//  Created by Wiktor Drab on 23/08/2025.
//

import SwiftUI

struct VerifyEmailView: View {
    @StateObject var viewModel: VerifyEmailViewModel
    @Environment(\.openURL) private var openURL
    
    @State private var tipsOpen = false
    @State private var isResending = false
    @State private var cooldownLeft = 0
    private let cooldownSeconds = 30

    private var canResend: Bool { !isResending && cooldownLeft == 0 }

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

                    ActionPill(title: resendTitle, system: "arrow.clockwise", disabled: !canResend) {
                        Task {
                            isResending = true
                            defer { isResending = false }
                            await viewModel.resendVerificationEmail()
                            startCooldown()
                        }
                    }
                }

                if cooldownLeft > 0 {
                    Text("You can request another email in \(cooldownLeft)s.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }

                if let error = viewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Text(error)
                    }
                    .font(.callout)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
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
        Button(role: .destructive) { viewModel.signOut() } label: {
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

    private var resendTitle: String {
        if isResending { return "Sending…" }
        if cooldownLeft > 0 { return "Resend (\(cooldownLeft)s)" }
        return "Resend email"
    }

    private func startCooldown() {
        cooldownLeft = cooldownSeconds
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            cooldownLeft = max(0, cooldownLeft - 1)
            if cooldownLeft == 0 { timer.invalidate() }
        }
    }
}

// MARK: - Subviews

private struct ActionPill: View {
    let title: String
    let system: String
    var disabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button {
            guard !disabled else { return }
            action()
        } label: {
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
                    .fill(Color.white.opacity(disabled ? 0.04 : 0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(disabled ? AnyShapeStyle(Color.white.opacity(0.12)) : AnyShapeStyle(LinearGradient(colors: [.cyan, .teal], startPoint: .leading, endPoint: .trailing)), lineWidth: 1)
            )
            .opacity(disabled ? 0.5 : 1.0)
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

#Preview {
    let appState = AppState()
    let viewModel = VerifyEmailViewModel(appState: appState, authService: AuthService())
    VerifyEmailView(viewModel: viewModel)
        .environmentObject(appState)
}

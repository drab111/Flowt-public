//
//  TermsAgreementView.swift
//  Flowt
//
//  Created by Wiktor Drab on 01/10/2025.
//

import SwiftUI

struct TermsAgreementView: View {
    @ObservedObject var infoVM: InfoViewModel
    @Binding var hasAccepted: Bool
    
    @State private var agreedTerms = false
    @State private var agreedPrivacy = false
    @State private var confirmedAge = false
    @State private var showTerms = false
    @State private var showPrivacy = false
    private var canAccept: Bool { agreedTerms && agreedPrivacy && confirmedAge }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerPanel
                agreementsPanel
                togglesPanel
                Spacer()
                buttonPanel
                Spacer(minLength: 30)
            }
        }
        .sheet(isPresented: $showTerms) { SafariSheet(url: infoVM.termsURL).accessibilityIdentifier("terms_modal") }
        .sheet(isPresented: $showPrivacy) { SafariSheet(url: infoVM.privacyURL).accessibilityIdentifier("privacy_modal") }
        .scrollBounceBehavior(.basedOnSize)
    }
    
    // MARK: - Panels
    private var headerPanel: some View {
        VStack(spacing: 6) {
            Text("Welcome to Flowt")
                .font(.title.bold())
                .foregroundStyle(.white)
            Text("Before you start, please review and accept.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
    }
    
    private var agreementsPanel: some View {
        EdgeLitContainer {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "User Agreement", subtitle: "What you’re agreeing to")
                
                Button {
                    showTerms = true
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    OutlineActionButtonLabel(
                        title: "Terms of Service",
                        systemImage: "doc.text.fill",
                        gradient: [.cyan, .teal]
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("terms_button")
                
                Divider()
                    .overlay(LinearGradient(colors: [.white.opacity(0.0), .white.opacity(0.25), .white.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
                    .padding(.vertical, 2)
                
                Button {
                    showPrivacy = true
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    OutlineActionButtonLabel(
                        title: "Privacy Policy",
                        systemImage: "lock.fill",
                        gradient: [.cyan, .teal]
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("privacy_button")
                
                Text("Last updated: October 2025")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.top, 2)
            }
            .overlay(alignment: .topTrailing) {
                FlowDecoration()
                    .opacity(0.15)
                    .padding(.trailing, 8)
                    .padding(.bottom, 6)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var togglesPanel: some View {
        EdgeLitContainer {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Consent", subtitle: "Please confirm")
                
                AgreementToggle(text: "I have read and agree to the Terms of Service.", isOn: $agreedTerms, accessibilityID: "toggle_terms")
                AgreementToggle(text: "I have read and agree to the Privacy Policy.", isOn: $agreedPrivacy, accessibilityID: "toggle_privacy")
                AgreementToggle(text: "I confirm I am at least 13 years old.", isOn: $confirmedAge, accessibilityID: "toggle_age")
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var buttonPanel: some View {
        AnimatedGradientButton(title: "Accept and Continue", symbol: "checkmark.seal.fill", gradientColors: animatedGradientButtonColors) {
            guard canAccept else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            hasAccepted = true
        }
        .opacity(canAccept ? 1 : 0.5)
        .disabled(!canAccept)
        .padding(.horizontal, 24)
        .accessibilityIdentifier("terms_acceptButton")
    }
}

// MARK: - Subviews
private struct AgreementToggle: View {
    let text: String
    @Binding var isOn: Bool
    var accessibilityID: String
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(text)
                .font(.body)
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .tint(.cyan)
        .accessibilityIdentifier(accessibilityID)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var accepted = false
    TermsAgreementView(infoVM: InfoViewModel(), hasAccepted: $accepted)
}
#endif

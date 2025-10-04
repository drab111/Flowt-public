//
//  TermsAgreementView.swift
//  Flowt
//
//  Created by Wiktor Drab on 01/10/2025.
//

import SwiftUI
import SafariServices

struct TermsAgreementView: View {
    @ObservedObject var infoVM: InfoViewModel
    @Binding var hasAccepted: Bool
    
    @State private var agreedTerms = false
    @State private var agreedPrivacy = false
    @State private var confirmedAge = false
    @State private var showTerms = false
    @State private var showPrivacy = false
    private var canAccept: Bool { agreedTerms && agreedPrivacy && confirmedAge }
    
    var body: some View {
        VStack(spacing: 20) {
            headerPanel
            agreementsPanel
            togglesPanel
            Spacer()
            buttonPanel
            Spacer(minLength: 30)
        }
        .sheet(isPresented: $showTerms) { SafariSheet(url: infoVM.termsURL) }
        .sheet(isPresented: $showPrivacy) { SafariSheet(url: infoVM.privacyURL) }
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
                
                Button { showTerms = true } label: {
                    OutlineActionButtonLabel(
                        title: "Terms of Service",
                        systemImage: "doc.text.fill",
                        gradient: [.cyan, .teal]
                    )
                }
                .buttonStyle(.plain)
                
                Divider()
                    .overlay(LinearGradient(colors: [.white.opacity(0.0), .white.opacity(0.25), .white.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
                    .padding(.vertical, 2)
                
                Button { showPrivacy = true } label: {
                    OutlineActionButtonLabel(
                        title: "Privacy Policy",
                        systemImage: "lock.fill",
                        gradient: [.cyan, .teal]
                    )
                }
                .buttonStyle(.plain)
                
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
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var togglesPanel: some View {
        EdgeLitContainer {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Consent", subtitle: "Please confirm")
                
                Toggle(isOn: $agreedTerms)  { Text("I have read and agree to the Terms of Service.") }
                    .tint(.cyan)
                
                Toggle(isOn: $agreedPrivacy)  { Text("I have read and agree to the Privacy Policy.") }
                    .tint(.cyan)
                
                Toggle(isOn: $confirmedAge)  { Text("I confirm I am at least 17 years old.") }
                    .tint(.cyan)
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
    }
}

#Preview {
    @Previewable @State var accepted = false
    TermsAgreementView(infoVM: InfoViewModel(), hasAccepted: $accepted)
}

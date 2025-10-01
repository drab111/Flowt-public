//
//  InfoView.swift
//  Flowt
//
//  Created by Wiktor Drab on 30/09/2025.
//

import SwiftUI

struct InfoView: View {
    @ObservedObject var infoVM: InfoViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: - Header
                VStack(spacing: 8) {
                    Text("About Flowt")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text("All the legal stuff and support in one place.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 8)
                .padding(.horizontal)
                .padding(.top, 35)
                
                
                // MARK: - Legal Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Legal")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Button(action: { infoVM.openPrivacyPolicy() }) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .gradientBackground()
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    
                    Button(action: { infoVM.openTermsOfService() }) {
                        Label("Terms of Service", systemImage: "doc.plaintext")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .gradientBackground()
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.03))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.15), lineWidth: 1))
                .padding(.horizontal)
                
                // MARK: - Community Guidelines Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Community Guidelines")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Avatars and nicknames are user-generated content. While we use automated filters to block inappropriate material, they may not always be accurate. By using Flowt, you agree not to upload or share content that is offensive, pornographic, hateful, or otherwise inappropriate. Violations may result in account removal.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                }
                .padding()
                .background(Color.white.opacity(0.03))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.15), lineWidth: 1))
                .padding(.horizontal)
                
                // MARK: - Support Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Support")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Button(action: { infoVM.contactSupport() }) {
                        Label("Contact Support", systemImage: "envelope.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.03))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.15), lineWidth: 1))
                .padding(.horizontal)
                
                
                // MARK: - App Info Section
                VStack(spacing: 8) {
                    Text("Flowt v1.0")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("© 2025 Wiktor Drab. All rights reserved.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    InfoView(infoVM: InfoViewModel())
}

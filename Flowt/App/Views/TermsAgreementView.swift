//
//  TermsAgreementView.swift
//  Flowt
//
//  Created by Wiktor Drab on 01/10/2025.
//

import SwiftUI

struct TermsAgreementView: View {
    @Binding var hasAccepted: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Welcome to Flowt")
                .font(.title.bold())
                .foregroundColor(.white)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Before you start playing, please review and accept our Terms of Service and Privacy Policy.")
                        .foregroundColor(.white.opacity(0.9))
                    
                    Link("Read Terms of Service", destination: URL(string: "https://respected-tuck-d26.notion.site/Flowt-27e268ff3eaa8019bc63deeb543e4f91?source")!)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Link("Read Privacy Policy", destination: URL(string: "https://respected-tuck-d26.notion.site/Flowt-27e268ff3eaa80ccbdffe9b63c1041ca?source")!)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("By tapping Accept, you confirm that you are at least 17 years old and agree to abide by these terms.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 8)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 6)
            }
            
            Spacer()
            
            Button {
                hasAccepted = true
            } label: {
                Text("Accept and Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .gradientBackground()
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 24)
            
            Spacer(minLength: 30)
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var accepted = false
    TermsAgreementView(hasAccepted: $accepted)
}

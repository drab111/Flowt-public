//
//  OutlineActionButtonLabel.swift
//  Flowt
//
//  Created by Wiktor Drab on 03/10/2025.
//

import SwiftUI

struct OutlineActionButtonLabel: View {
    var title: String
    var systemImage: String
    var gradient: [Color]
    
    // MARK: - Body
    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.body)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
    }
}

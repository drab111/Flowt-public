//
//  EdgeLitContainer.swift
//  Flowt
//
//  Created by Wiktor Drab on 03/10/2025.
//

import SwiftUI

struct EdgeLitContainer<Content: View>: View {
    var cornerRadius: CGFloat = 20
    var contentPadding: CGFloat = 18
    @ViewBuilder var content: Content
    @State private var sweep = false
    
    // MARK: - Body
    var body: some View {
        content
            .padding(contentPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        // Animation
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(.clear)
                            .overlay(
                                Rectangle()
                                    .fill(LinearGradient(colors: [.clear, .white.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing))
                                    .rotationEffect(.degrees(-12))
                                    .offset(x: sweep ? 380 : -380)
                                    .allowsHitTesting(false)
                            )
                            .mask(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(lineWidth: 1.5)
                                    .blur(radius: 2)
                            )
                    )
                    .overlay(
                        // Lighten the top edge
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(LinearGradient(colors: [Color.white.opacity(0.15), .clear], startPoint: .top, endPoint: .center), lineWidth: 0.5)
                            .blendMode(.plusLighter)
                    )
            )
            .shadow(color: .black.opacity(0.35), radius: 14, x: 0, y: 8)
            .padding(.horizontal, 2)
            .onAppear {
                withAnimation(.easeInOut(duration: 7.0).repeatForever(autoreverses: false)) { sweep.toggle() }
            }
    }
}

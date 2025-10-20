//
//  FlowDecoration.swift
//  Flowt
//
//  Created by Wiktor Drab on 03/10/2025.
//

import SwiftUI

// Displays dots connected with lines
struct FlowDecoration: View {
    @State private var phase: CGFloat = 0
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 6) {
            port; segment; port; segment; port; segment; port
        }
        .onAppear {
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) { phase = .pi * 2 }
        }
    }
    
    // MARK: - Subviews
    private var port: some View {
        Circle()
            .fill(.white.opacity(0.22))
            .frame(width: 6, height: 6)
            .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 0.6))
    }
    
    private var segment: some View {
        Capsule()
            .fill(LinearGradient(colors: [.cyan.opacity(0.6), .teal.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
            .frame(width: 24, height: 3)
    }
}

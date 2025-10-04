//
//  AnimatedGradientButton.swift
//  Flowt
//
//  Created by Wiktor Drab on 03/10/2025.
//

import SwiftUI

struct AnimatedGradientButton: View {
    var title: String
    var symbol: String
    var gradientColors: [Color]
    var action: () -> Void
    
    @State private var gradientShift = false
    @State private var glowPulse = false
    @State private var pressed = false
    
    var body: some View {
        Button(action: {
            Task {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { pressed = true }
                try? await Task.sleep(nanoseconds: 150_000_000)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { pressed = false }
                action()
            }
        }) {
            Label(title, systemImage: symbol)
                .font(.body)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .frame(height: 24)
                .padding(.vertical, 12)
                .foregroundColor(.white)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: gradientShift ? .leading : .trailing,
                        endPoint: gradientShift ? .trailing : .leading
                    )
                    .animation(.linear(duration: 8).repeatForever(autoreverses: true), value: gradientShift)
                )
                .cornerRadius(20)
                .shadow(color: Color.blue.opacity(glowPulse ? 0.6 : 0.2), radius: glowPulse ? 20 : 8)
                .scaleEffect(pressed ? 0.96 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowPulse)
        }
        .onAppear {
            gradientShift = true
            glowPulse = true
        }
    }
}

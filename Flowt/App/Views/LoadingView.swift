//
//  LoadingView.swift
//  Flowt
//
//  Created by Wiktor Drab on 26/08/2025.
//

import SwiftUI

struct LoadingView: View {
    @State private var appear = false
    @State private var pulse = false
    @State private var sheen = false
    
    let accentGradient = LinearGradient(
        colors: [
            Color(red: 0.02, green: 0.06, blue: 0.15).opacity(0.95),
            Color(red: 0.1, green: 0.2, blue: 0.32).opacity(0.90)
        ], startPoint: .topLeading, endPoint: .bottomTrailing
    )
    let accentColor1 = Color(red: 0.12, green: 0.22, blue: 0.35).opacity(0.92)
    let accentColor2 = Color(red: 0.02, green: 0.06, blue: 0.15).opacity(0.95)

    var body: some View {
        ZStack {
            AnimatedBlobBackground(color1: accentColor1, color2: accentColor2)

            VStack(spacing: 20) {
                ZStack {
                    // glow za logiem
                    Circle()
                        .fill(RadialGradient(colors: [accentColor1, .clear], center: .center, startRadius: 4, endRadius: 140))
                        .frame(width: 170, height: 170)
                        .blur(radius: 16)
                        .opacity(appear ? 1 : 0)

                    // logo
                    Image("FlowtLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(.clear)
                                .overlay(
                                    Rectangle()
                                        .fill(LinearGradient(
                                            colors: [.clear, .white.opacity(0.28), .clear],
                                            startPoint: .leading, endPoint: .trailing
                                        ))
                                        .rotationEffect(.degrees(-18))
                                        .offset(x: sheen ? 260 : -260)
                                )
                                .mask(
                                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                                        .stroke(lineWidth: 1.2)
                                        .blur(radius: 1.5)
                                )
                        )
                        .scaleEffect(pulse ? 1.03 : 1.0)
                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: pulse)
                }

                Text("Flowt")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 10)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.05), value: appear)

                Text("Loading…")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.75))
                    .opacity(pulse ? 0.95 : 0.35)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
            }
            .padding(.horizontal, 24)
        }
        .ignoresSafeArea()
        .onAppear {
            appear = true
            pulse = true
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: false)) {
                sheen.toggle()
            }
        }
    }
}

// MARK: - Animowane tło
private struct AnimatedBlobBackground: View {
    let color1: Color
    let color2: Color
    @State private var moveA = false
    @State private var moveB = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [color1, color2], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            Circle()
                .fill(RadialGradient(colors: [color1, .clear], center: .center, startRadius: 2, endRadius: 240))
                .frame(width: 360, height: 360)
                .offset(x: moveA ? -120 : 80, y: moveA ? -140 : 40)
                .blur(radius: 50)
                .blendMode(.plusLighter)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: moveA)

            Circle()
                .fill(RadialGradient(colors: [color2, .clear], center: .center, startRadius: 2, endRadius: 240))
                .frame(width: 320, height: 320)
                .offset(x: moveB ? 120 : -60, y: moveB ? 140 : -30)
                .blur(radius: 50)
                .blendMode(.plusLighter)
                .animation(.easeInOut(duration: 9.5).repeatForever(autoreverses: true), value: moveB)
        }
        .onAppear {
            moveA = true
            moveB = true
        }
    }
}

#Preview {
    LoadingView()
}

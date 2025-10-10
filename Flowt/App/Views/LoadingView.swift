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

    // MARK: - Body
    var body: some View {
        ZStack {
            BackgroundView(withLogo: false)

            VStack(spacing: 20) {
                ZStack {
                    // Glow behind the logo
                    Circle()
                        .fill(RadialGradient(colors: [Color(red: 0.12, green: 0.22, blue: 0.35).opacity(0.92), .clear], center: .center, startRadius: 4, endRadius: 140))
                        .frame(width: 170, height: 170)
                        .blur(radius: 16)
                        .opacity(appear ? 1 : 0)
                        .accessibilityHidden(true)

                    // Logo
                    Image("FlowtLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
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
                        .scaleEffect(pulse ? 1.01 : 1.0)
                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: pulse)
                        .accessibilityLabel("Flowt")
                }

                Text("Flowt")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 10)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.05), value: appear)
                    .accessibilityHidden(true)

                Text("Loading…")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.75))
                    .opacity(pulse ? 0.95 : 0.35)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                    .accessibilityHidden(true)
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

#if DEBUG
#Preview {
    LoadingView()
}
#endif

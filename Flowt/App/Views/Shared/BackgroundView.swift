//
//  BackgroundView.swift
//  Flowt
//
//  Created by Wiktor Drab on 09/09/2025.
//

import SwiftUI

var animatedGradientButtonColors: [Color] = [
    Color(red: 0.0, green: 0.65, blue: 0.8).opacity(0.5),
    Color(red: 0.0, green: 0.55, blue: 0.55).opacity(0.4),
    Color(red: 0.0, green: 0.65, blue: 0.8).opacity(0.5)
]

struct BackgroundView: View {
    var withLogo: Bool = true
    var hasBottomBar: Bool = true
    @State private var wavePhase: CGFloat = 0
    @State private var glowOpacity: Double = 0.08
    @State private var logoOpacity: Double = 0.05
    
    var body: some View {
        ZStack {
            // Gradient oceaniczny
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.0, green: 0.08, blue: 0.20),
                    Color(red: 0.0, green: 0.12, blue: 0.25),
                    Color(red: 0.0, green: 0.17, blue: 0.32),
                    Color(red: 0.0, green: 0.08, blue: 0.20)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Smugi światła
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(glowOpacity),
                    Color.clear,
                    Color.white.opacity(glowOpacity * 0.8),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.overlay)
            .rotationEffect(.degrees(-10))
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                    glowOpacity = 0.15
                }
            }
            
            // Animowane fale
            GeometryReader { geo in
                ZStack {
                    AnimatedWave(amplitude: 14, frequency: 2.5, phase: wavePhase)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: geo.size.height * 0.5)
                        .offset(y: geo.size.height * (hasBottomBar ? 0.48 : 0.55))
                    
                    AnimatedWave(amplitude: 9, frequency: 3.5, phase: wavePhase + .pi/2)
                        .fill(Color.white.opacity(0.04))
                        .frame(height: geo.size.height * 0.55)
                        .offset(y: geo.size.height * (hasBottomBar ? 0.58 : 0.65))
                }
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                    wavePhase = .pi * 2
                }
            }
            
            // Logo watermark
            if withLogo {
                Image("FlowtLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280, height: 280)
                    .opacity(logoOpacity)
                    .blur(radius: 1.5)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                            logoOpacity = 0.12
                        }
                    }
            }
        }
    }
    
    struct AnimatedWave: Shape {
        var amplitude: CGFloat
        var frequency: CGFloat
        var phase: CGFloat
        
        // nadpisujemy zmienną wbudowaną w Shape (mówimy co ma być zmieniane podczas animacji w onAppear)
        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let midHeight = rect.height / 2
            path.move(to: CGPoint(x: 0, y: midHeight))
            
            for x in stride(from: 0, through: rect.width, by: 2) {
                let relativeX = x / rect.width
                let y = midHeight + sin(relativeX * .pi * frequency + phase) * amplitude
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
            
            return path
        }
    }
}

struct GradientBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(LinearGradient(colors: [
                    Color(red: 0.0, green: 0.25, blue: 0.55),
                    Color(red: 0.1, green: 0.4, blue: 0.75),
                    Color(red: 0.3, green: 0.2, blue: 0.6)
                ], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

extension View {
    public func gradientBackground() -> some View {
        modifier(GradientBackground())
    }
}

//
//  BackgroundView.swift
//  Flowt
//
//  Created by Wiktor Drab on 09/09/2025.
//

import SwiftUI

struct BackgroundView: View {
    var withLogo: Bool = true
    var hasBottomBar: Bool = true
    var enableParallax: Bool = false
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var parallaxX: CGFloat = 0
    @State private var parallaxY: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            
            ZStack {
                // deep ocean gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.01, green: 0.05, blue: 0.12),
                        Color(red: 0.01, green: 0.10, blue: 0.22),
                        Color(red: 0.02, green: 0.16, blue: 0.30),
                        Color(red: 0.01, green: 0.08, blue: 0.18)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // vignette for contrast
                RadialGradient(
                    colors: [Color.clear, Color.black.opacity(0.35)],
                    center: .center,
                    startRadius: 0, endRadius: max(size.width, size.height)
                )
                .ignoresSafeArea()
                .blendMode(.multiply)
                
                // aurora beams (animated sheen bands)
                AuroraBeams()
                    .opacity(0.6)
                    .blendMode(.screen)
                    .offset(x: parallaxX * 0.5, y: parallaxY * 0.5)
                
                // subtle sea network lines with flowing dash
                SeaCanvas()
                    .opacity(0.18)
                    .offset(x: parallaxX * 0.3, y: parallaxY * 0.3)
                
                // animated waves (respect bottom bar offset)
                WavesLayer(hasBottomBar: hasBottomBar, reduceMotion: reduceMotion)
                    .offset(x: parallaxX * 0.2, y: parallaxY * 0.2)
                
                // logo watermark
                if withLogo {
                    LogoWatermark()
                        .frame(width: min(320, size.width * 0.7), height: min(320, size.width * 0.7))
                        .offset(y: -size.height * (hasBottomBar ? 0.04 : 0.02))
                        .offset(x: parallaxX * 0.1, y: parallaxY * 0.1)
                        .allowsHitTesting(false)
                }
            }
            .contentShape(Rectangle())
            .modifier(ParallaxGesture(enabled: enableParallax))
        }
    }
}

private struct WavesLayer: View {
    var hasBottomBar: Bool
    var reduceMotion: Bool
    
    @State private var phase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { _ in
            GeometryReader { geo in
                let h = geo.size.height
                ZStack {
                    AnimatedWave(amplitude: 14, frequency: 2.4, phase: phase)
                        .fill(Color.white.opacity(0.06))
                        .frame(height: h * 0.50)
                        .offset(y: h * (hasBottomBar ? 0.48 : 0.55))
                        .blur(radius: 0.2)
                    AnimatedWave(amplitude: 9, frequency: 3.4, phase: phase + .pi/2)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: h * 0.55)
                        .offset(y: h * (hasBottomBar ? 0.58 : 0.65))
                        .blur(radius: 0.2)
                }
                .onAppear {
                    guard !reduceMotion else { return }
                    withAnimation(.linear(duration: 14).repeatForever(autoreverses: false)) {
                        phase = .pi * 2
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

private struct AnimatedWave: Shape {
    var amplitude: CGFloat
    var frequency: CGFloat
    var phase: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let mid = rect.height / 2
        p.move(to: CGPoint(x: 0, y: mid))
        for x in stride(from: 0, through: rect.width, by: 2) {
            let r = x / rect.width
            let y = mid + sin(r * .pi * frequency + phase) * amplitude
            p.addLine(to: CGPoint(x: x, y: y))
        }
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        return p
    }
}

private struct AuroraBeams: View {
    @State private var t: CGFloat = -1
    
    var body: some View {
        ZStack {
            beam(width: 380, rotation: -18, baseOpacity: 0.30)
            beam(width: 260, rotation: 10,  baseOpacity: 0.24)
            beam(width: 320, rotation: -42, baseOpacity: 0.20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) { t = 1 }
        }
    }
    
    private func beam(width: CGFloat, rotation: Double, baseOpacity: Double) -> some View {
        LinearGradient(
            colors: [
                Color.cyan.opacity(0.00),
                Color.cyan.opacity(baseOpacity * 0.9),
                Color.teal.opacity(baseOpacity),
                Color.cyan.opacity(0.00)
            ],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(width: width, height: 600)
        .rotationEffect(.degrees(rotation))
        .offset(x: t * 40, y: 0)
        .blur(radius: 6)
        .blendMode(.screen)
    }
}

// (dashed lines + flowing phase)
private struct SeaCanvas: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let paths = SeaCanvas.makePaths(in: size)
                let line = StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [6, 10], dashPhase: phase)
                
                // Lines
                for path in paths { ctx.stroke(path, with: .color(.white.opacity(0.6)), style: line) }
            }
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) { phase = 40 }
            }
        }
        .allowsHitTesting(false)
    }
    
    private static func makePaths(in size: CGSize) -> [Path] {
        // A few smooth curves across the screen
        var paths: [Path] = []
        func curve(_ a: CGPoint, _ c1: CGPoint, _ c2: CGPoint, _ b: CGPoint) -> Path {
            var p = Path()
            p.move(to: a)
            p.addCurve(to: b, control1: c1, control2: c2)
            return p
        }
        let w = size.width, h = size.height
        
        paths.append(curve(CGPoint(x: -40, y: h*0.25), CGPoint(x: w*0.25, y: h*0.10), CGPoint(x: w*0.45, y: h*0.40), CGPoint(x: w+40, y: h*0.30)))
        paths.append(curve(CGPoint(x: -40, y: h*0.60), CGPoint(x: w*0.20, y: h*0.50), CGPoint(x: w*0.55, y: h*0.75), CGPoint(x: w+40, y: h*0.65)))
        paths.append(curve(CGPoint(x: -40, y: h*0.80), CGPoint(x: w*0.30, y: h*0.72), CGPoint(x: w*0.60, y: h*0.95), CGPoint(x: w+40, y: h*0.88)))
        return paths
    }
}

private struct LogoWatermark: View {
    @State private var opacity: Double = 0.07
    @State private var drift: CGFloat = -5
    
    var body: some View {
        Image("FlowtLogo")
            .resizable()
            .scaledToFit()
            .opacity(opacity)
            .blur(radius: 1.2)
            .offset(y: drift)
            .onAppear {
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    opacity = 0.12
                }
                withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    drift = 5
                }
            }
    }
}

private struct ParallaxGesture: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var enabled: Bool
    @State private var x: CGFloat = 0
    @State private var y: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .gesture(enabled && !reduceMotion ? DragGesture(minimumDistance: 16) // ignores simple taps
                    .onChanged { value in
                        let size = UIScreen.main.bounds.size
                        x = (value.location.x / size.width - 0.5) * 10
                        y = (value.location.y / size.height - 0.5) * 10
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.6)) { x = 0; y = 0 }
                    }
                : nil
            )
    }
}

// MARK: - App style

var animatedGradientButtonColors: [Color] = [
    Color(red: 0.0, green: 0.65, blue: 0.8).opacity(0.5),
    Color(red: 0.0, green: 0.55, blue: 0.55).opacity(0.4),
    Color(red: 0.0, green: 0.65, blue: 0.8).opacity(0.5)
]

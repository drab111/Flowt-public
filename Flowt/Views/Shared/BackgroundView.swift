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
    
    var body: some View {
        ZStack {
            // Gradient morski
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.25),
                    Color(red: 0.12, green: 0.35, blue: 0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Warstwy fal
            GeometryReader { geo in
                ZStack {
                    WaveShape(amplitude: 40, frequency: 1.5)
                        .fill(Color.white.opacity(0.06))
                        .frame(height: geo.size.height * 0.45)
                        .offset(y: geo.size.height * (hasBottomBar ? 0.45 : 0.6))
                    
                    WaveShape(amplitude: 25, frequency: 2.5)
                        .fill(Color.white.opacity(0.04))
                        .frame(height: geo.size.height * 0.55)
                        .offset(y: geo.size.height * (hasBottomBar ? 0.5 : 0.65))
                    
                    WaveShape(amplitude: 15, frequency: 3.0)
                        .fill(Color.white.opacity(0.03))
                        .frame(height: geo.size.height * 0.65)
                        .offset(y: geo.size.height * (hasBottomBar ? 0.55 : 0.7))
                }
            }
            
            // Delikatna siatka morska
            GeometryReader { geo in
                Path { path in
                    let spacing: CGFloat = 120
                    for x in stride(from: 0, through: geo.size.width, by: spacing) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geo.size.height))
                    }
                    for y in stride(from: 0, through: geo.size.height, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.02), lineWidth: 1)
            }
            
            // Watermark
            if withLogo {
                Image("FlowtLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320, height: 320)
                    .opacity(0.07)
            }
        }
    }
}

struct WaveShape: Shape {
    var amplitude: CGFloat
    var frequency: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midHeight = rect.height / 2
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / rect.width
            let y = midHeight + sin(relativeX * .pi * frequency) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

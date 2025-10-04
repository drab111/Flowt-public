//
//  ScoreBar.swift
//  Flowt
//
//  Created by Wiktor Drab on 03/10/2025.
//

import SwiftUI

// Liniowy pasek wyników z delikatnym pulsem
struct ScoreBar: View {
    let progress: CGFloat
    let label: String
    @State private var pulse = false
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.08)).frame(height: 8)
                GeometryReader { geo in
                    Capsule()
                        .fill(LinearGradient(colors: [.cyan, .teal], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(8, geo.size.width * min(progress, 1)), height: 8)
                        .shadow(color: .cyan.opacity(0.6), radius: pulse ? 8 : 2)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulse)
                }
                .frame(height: 8)
            }
            .clipShape(Capsule())
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
        }
        .onAppear { pulse = true }
    }
}

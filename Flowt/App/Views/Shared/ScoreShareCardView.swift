//
//  ScoreShareCardView.swift
//  Flowt
//
//  Created by Wiktor Drab on 05/10/2025.
//

import SwiftUI

struct ScoreShareCardView: View {
    let score: Int
    let rank: Int?
    let nickname: String?

    // MARK: - Body
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.01, green: 0.08, blue: 0.18),
                            Color(red: 0.01, green: 0.10, blue: 0.22),
                            Color(red: 0.02, green: 0.16, blue: 0.30)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color.cyan.opacity(0.18), Color.teal.opacity(0.12), .clear],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .blur(radius: 18)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 12)

            VStack(spacing: 14) {
                Image("FlowtLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 72)
                    .shadow(radius: 6)

                // Nickname + rank (if available)
                HStack(spacing: 8) {
                    Spacer()
                    if let nickname, !nickname.isEmpty {
                        Text(nickname)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.92))
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(Capsule().stroke(.white.opacity(0.22), lineWidth: 0.8))
                    }

                    if let rank {
                        Label("Rank #\(rank)", systemImage: "crown.fill")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(Capsule().stroke(.white.opacity(0.22), lineWidth: 0.8))
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Score
                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                        .minimumScaleFactor(0.6)

                    Text("SCORE")
                        .font(.footnote.weight(.semibold))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(.top, 2)

                // Subtle divider
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white.opacity(0.10))
                    .frame(height: 2)
                    .overlay(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.35), .clear],
                            startPoint: .leading, endPoint: .trailing
                        )
                        .blendMode(.screen)
                        .mask(
                            WaveMask()
                                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        )
                    )
                    .padding(.horizontal, 8)
                    .padding(.top, 6)
            }
            .padding(24)
        }
        .padding(16)
        .background(Color.black)
    }
}

// MARK: - Subviews
private struct WaveMask: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let midY = rect.midY
        p.move(to: CGPoint(x: rect.minX, y: midY))
        for x in stride(from: rect.minX, through: rect.maxX, by: 3) {
            let r = (x - rect.minX) / rect.width
            let y = midY + sin(r * .pi * 2.0) * 2.5
            p.addLine(to: CGPoint(x: x, y: y))
        }
        return p
    }
}

// MARK: - Helpers
struct ScoreSharePayload: Transferable {
    let imageData: Data // PNG scorecard

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { payload in
            payload.imageData
        }
        .suggestedFileName("flowt_score")
    }
}

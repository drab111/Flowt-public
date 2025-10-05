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

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.0, green: 0.65, blue: 0.8).opacity(0.5),
                            Color(red: 0.0, green: 0.55, blue: 0.55).opacity(0.4)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 2)
                )

            VStack(spacing: 12) {
                Image("FlowtLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 76)
                    .shadow(radius: 6)

                Text("Score: \(score)")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                if let rank {
                    Label("Rank #\(rank)", systemImage: "crown.fill")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.25), lineWidth: 0.8))
                }

                Text("Think you can beat me?")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
            }
            .padding(24)
        }
        .padding(16)
        .background(Color.black)
    }
}

struct ScoreSharePayload: Transferable {
    let imageData: Data // PNG karty wyniku

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { payload in
            payload.imageData
        }
        .suggestedFileName("flowt_score")
    }
}

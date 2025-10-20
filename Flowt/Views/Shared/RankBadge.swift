//
//  RankBadge.swift
//  Flowt
//
//  Created by Wiktor Drab on 03/10/2025.
//

import SwiftUI

// Rank with medal color for top 3 positions
struct RankBadge: View {
    let rank: Int
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Capsule()
                .fill(rankGradient.opacity(0.22))
                .overlay(Capsule().stroke(rankGradient, lineWidth: 1))
                .frame(width: 56, height: 30)
            HStack(spacing: 6) {
                if rank <= 3 {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(rankGradient)
                }
                Text("#\(rank)")
                    .font(.footnote.weight(.heavy))
                    .foregroundStyle(.white)
            }
        }
    }
    
    // MARK: - Helpers
    private var rankGradient: LinearGradient {
        switch rank {
        case 1: return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 2: return LinearGradient(colors: [.white, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 3: return LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        default: return LinearGradient(colors: [.white.opacity(0.85), .cyan.opacity(0.9)], startPoint: .top, endPoint: .bottom)
        }
    }
}

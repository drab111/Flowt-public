//
//  LeaderboardView.swift
//  Flowt
//
//  Created by Wiktor Drab on 25/09/2025.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var scoreVM: ScoreViewModel
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 22) {
                    headerPanel
                    podiumPanel
                    if let you = scoreVM.leaderboard.first(where: { $0.isCurrentUser }) {
                        yourPositionPanel(entry: you.entry, profile: you.profile)
                    }
                    listPanel
                }
                .padding(.horizontal)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .refreshable {
                await scoreVM.loadLeaderboard(limit: 30)
                scoreVM.errorMessage = nil
            }
            .accessibilityIdentifier("leaderboard_scrollView")
            
            // Loading
            if scoreVM.isLoading == true {
                ProgressView()
                    .scaleEffect(1.6)
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.25))
                    .ignoresSafeArea()
            }
        }
        .task { await scoreVM.loadLeaderboard(limit: 30) }
    }
    
    // MARK: - Panels
    private var headerPanel: some View {
        EdgeLitContainer {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: "Leaderboard", subtitle: "Global Top 30")
                    
                    Divider()
                        .overlay(LinearGradient(colors: [.white.opacity(0.0), .white.opacity(0.25), .white.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
                        .padding(.vertical, 2)
                    
                    if let error = scoreVM.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.top, 2)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                            Text("Great ranks come with calm navigation, not haste.")
                        }
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.7))
                    }
                }
                Spacer()
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    Task { await scoreVM.loadLeaderboard(limit: 30) }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(LinearGradient(colors: [.cyan, .teal], startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Refresh leaderboard")
                .accessibilityHint("Reloads the top 30 scores.")
                .accessibilityIdentifier("leaderboard_refreshButton")
            }
        }
    }
    
    private var podiumPanel: some View {
        EdgeLitContainer {
            let topThree: [(entry: ScoreEntry, profile: UserProfile?)] = Array(scoreVM.leaderboard.prefix(3)).map { ($0.entry, $0.profile) }
            PodiumView(items: topThree)
        }
    }
    
    private func yourPositionPanel(entry: ScoreEntry, profile: UserProfile?) -> some View {
        EdgeLitContainer {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "Your Best Position", subtitle: "Pinned")
                LeaderboardRowCard(
                    index: (scoreVM.leaderboard.firstIndex(where: { $0.entry.id == entry.id }) ?? 0) + 1,
                    profile: profile,
                    entry: entry,
                    topScore: scoreVM.leaderboard.first?.entry.score ?? entry.score,
                    highlight: true
                )
            }
        }
    }
    
    private var listPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "All Players", subtitle: "Detailed list")
            
            LazyVStack(spacing: 10) {
                ForEach(Array(scoreVM.leaderboard.enumerated()), id: \.0) { index, item in
                    LeaderboardRowCard(
                        index: index + 1,
                        profile: item.profile,
                        entry: item.entry,
                        topScore: scoreVM.leaderboard.first?.entry.score ?? item.entry.score,
                        highlight: item.isCurrentUser
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                if scoreVM.leaderboard.isEmpty && scoreVM.isLoading == false { emptyState }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.7))
            Text("No entries yet")
                .foregroundStyle(.white.opacity(0.9))
                .font(.headline)
            Text("Play a round to appear on the board.")
                .foregroundStyle(.white.opacity(0.6))
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(LinearGradient(colors: [.white.opacity(0.12), .clear], startPoint: .top, endPoint: .bottom), lineWidth: 1)
        )
        .padding(.top, 4)
    }
}

// MARK: - Subviews
private struct PodiumView: View { // Top 3 players with crowns and soft highlight
    let items: [(entry: ScoreEntry, profile: UserProfile?)]
    
    var body: some View {
        let first = items.first
        let second = items.dropFirst().first
        let third = items.dropFirst(2).first
        
        VStack(spacing: 16) {
            HStack(alignment: .bottom, spacing: 14) {
                PodiumColumn(rank: 2, item: second, height: 110)
                PodiumColumn(rank: 1, item: first,  height: 140, isPrimary: true)
                PodiumColumn(rank: 3, item: third,  height: 95)
            }
            .padding(.top, 4)
            
            // Display best score again
            if let lead = first {
                HStack(spacing: 10) {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Text(lead.profile?.nickname ?? "Unknown")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(lead.entry.score)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(LinearGradient(colors: [.white, .cyan], startPoint: .top, endPoint: .bottom))
                }
                .padding(.horizontal, 4)
                .padding(.top, 2)
            }
        }
    }
}

private struct PodiumColumn: View {
    let rank: Int
    let item: (entry: ScoreEntry, profile: UserProfile?)?
    let height: CGFloat
    var isPrimary: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                AvatarCircle(base64: item?.profile?.avatarBase64, fallback: "FlowtLogo", size: isPrimary ? 70 : 60)
                    .shadow(color: glowColor.opacity(isPrimary ? 0.55 : 0.35), radius: isPrimary ? 16 : 10, x: 0, y: 4)
                    .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 2))
                    .overlay(alignment: .bottom) {
                        if let nickname = item?.profile?.nickname {
                            Text(nickname)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial, in: Capsule())
                                .foregroundColor(.white)
                                .offset(y: 16)
                        }
                    }
                if rank <= 3 {
                    Image(systemName: "crown.fill")
                        .font(.system(size: isPrimary ? 18 : 14))
                        .foregroundStyle(crownGradient)
                        .offset(x: 6, y: -6)
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                }
            }
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                .frame(width: isPrimary ? 80 : 62, height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(LinearGradient(colors: [.cyan.opacity(0.5), .teal.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
                .overlay(alignment: .bottom) {
                    if let score = item?.entry.score {
                        Text("\(score)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.bottom, 6)
                    }
                }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
    
    private var glowColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .cyan
        }
    }
    
    private var crownGradient: LinearGradient {
        switch rank {
        case 1: return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 2: return LinearGradient(colors: [.white, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 3: return LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        default: return LinearGradient(colors: [.cyan, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

private struct LeaderboardRowCard: View {
    let index: Int
    let profile: UserProfile?
    let entry: ScoreEntry
    let topScore: Int
    var highlight: Bool = false
    
    @State private var sweep = false
    
    var body: some View {
        ZStack {
            // Highlight when the score belongs to the player
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(highlight ? 0.09 : 0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: highlight ? [Color.cyan, Color.teal] : [Color.white.opacity(0.14), .clear],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: highlight ? 1.2 : 1
                        )
                )
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
            
            // Animated shine effect
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.clear)
                .overlay(
                    Rectangle()
                        .fill(LinearGradient(colors: [.clear, .white.opacity(0.30), .clear], startPoint: .leading, endPoint: .trailing))
                        .rotationEffect(.degrees(-14))
                        .offset(x: sweep ? 360 : -360)
                        .allowsHitTesting(false)
                )
                .mask(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(lineWidth: 1.0)
                        .blur(radius: 1.6)
                )
                .onAppear {
                    withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: false)) { sweep.toggle() }
                }
            
            HStack(spacing: 12) {
                RankBadge(rank: index)
                    .accessibilityLabel("Rank \(index)")
                
                AvatarCircle(base64: profile?.avatarBase64, fallback: "FlowtLogo", size: 42)
                    .overlay(Circle().stroke(Color.white.opacity(0.55), lineWidth: 1))
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(profile?.nickname ?? "Unknown")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        
                        if highlight {
                            Text("You")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6).padding(.vertical, 3)
                                .background(
                                    Capsule().fill(LinearGradient(colors: [.cyan.opacity(0.6), .teal.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                                )
                                .overlay(Capsule().stroke(.white.opacity(0.25), lineWidth: 0.5))
                                .foregroundColor(.white)
                        }
                    }
                    
                    ScoreBar(progress: progress, label: "\(entry.score)")
                }
                
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
        }
        .overlay(alignment: .bottomTrailing) {
            FlowDecoration()
                .opacity(0.14)
                .padding(.trailing, 8)
                .padding(.bottom, 6)
                .accessibilityHidden(true)
        }
    }
    
    private var progress: CGFloat {
        guard topScore > 0 else { return 0 }
        return CGFloat(entry.score) / CGFloat(topScore)
    }
}

#if DEBUG
#Preview {
    let appState = AppState()
    LeaderboardView(scoreVM: ScoreViewModel(appState: appState, scoreService: ScoreService(), profileService: ProfileService()))
}
#endif

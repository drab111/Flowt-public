//
//  EndGameView.swift
//  Flowt
//
//  Created by Wiktor Drab on 24/09/2025.
//

import SwiftUI

struct EndGameView: View {
    @ObservedObject var gameVM: GameViewModel
    @ObservedObject var scoreVM: ScoreViewModel
    
    @State private var sheen = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            BackgroundView()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 22) {
                    Spacer(minLength: 30)
                    scorePanel
                    topFivePanel
                    Spacer()
                    actionsPanel
                }
                .padding(.horizontal)
                .padding(.top, 30)
                .padding(.bottom, 30)
            }
            .scrollBounceBehavior(.basedOnSize)
            .accessibilityIdentifier("endGame_scrollView")
        }
        .task { await scoreVM.saveAndLoadLeaderboard(limit: 3) }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: false)) { sheen.toggle() }
        }
    }
    
    // MARK: - Panels
    private var scorePanel: some View {
        EdgeLitContainer {
            VStack(spacing: 14) {
                SectionHeader(title: "Your Score", subtitle: "Latest run")
                
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text("\(scoreVM.score ?? 0)")
                        .font(.system(size: 54, weight: .heavy, design: .rounded))
                        .foregroundStyle(LinearGradient(colors: [.white, .cyan], startPoint: .top, endPoint: .bottom))
                        .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 2)
                    
                    if let rank = scoreVM.userRank {
                        Label("Rank #\(rank)", systemImage: "crown.fill")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 0.8))
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .overlay(LinearGradient(colors: [.white.opacity(0.0), .white.opacity(0.25), .white.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
                    .padding(.vertical, 2)
                
                if let error = scoreVM.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 2)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Smooth routes beat rushed ones.")
                    }
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    private var topFivePanel: some View {
        EdgeLitContainer {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Top 3", subtitle: "Global snapshot")
                
                if scoreVM.isLoading == true || scoreVM.leaderboard.isEmpty {
                    HStack {
                        ProgressView().tint(.white)
                        Text("Loading leaderboard...")
                            .foregroundStyle(.white.opacity(0.8))
                            .font(.callout)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(Array(scoreVM.leaderboard.prefix(3).enumerated()), id: \.0) { index, item in
                            ResultRowCard(
                                index: index + 1,
                                profile: item.profile,
                                entry: item.entry,
                                topScore: scoreVM.leaderboard.first?.entry.score ?? item.entry.score,
                                highlight: item.isCurrentUser,
                                latest: item.isLatest
                            )
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                }
            }
        }
    }
    
    private var actionsPanel: some View {
        VStack(spacing: 12) {
            if let payload = scoreVM.sharePayload {
                ShareLink(
                    items: [payload],
                    subject: Text("My Flowt score"),
                    message: Text("Try to beat me!"),
                    preview: { (_: ScoreSharePayload) in
                        SharePreview("Flowt Score", image: Image("FlowtLogo"))
                    },
                    label: {
                        OutlineActionButtonLabel(
                            title: "Share Score",
                            systemImage: "square.and.arrow.up",
                            gradient: [.cyan, .teal]
                        )
                    }
                )
                .buttonStyle(.plain)
                .padding(.horizontal, 35)
            } else {
                // Text fallback (when rendering fails)
                ShareLink(
                    item: "I scored \(scoreVM.score ?? 0) in Flowt.",
                    subject: Text("My Flowt score"),
                    message: Text("Think you can beat me?")
                ) {
                    OutlineActionButtonLabel(
                        title: "Share Score",
                        systemImage: "square.and.arrow.up",
                        gradient: [.cyan, .teal]
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 35)
            }

            AnimatedGradientButton(
                title: "Back to Menu",
                symbol: "rectangle.portrait.and.arrow.right",
                gradientColors: animatedGradientButtonColors
            ) { gameVM.backToMenu() }
            .padding(.horizontal, 65)
            .accessibilityIdentifier("endGame_backToMenuButton")
        }
    }
}

// MARK: - Subviews
private struct ResultRowCard: View {
    let index: Int
    let profile: UserProfile?
    let entry: ScoreEntry
    let topScore: Int
    var highlight: Bool = false
    var latest: Bool = false
    
    @State private var sweep = false
    
    var body: some View {
        ZStack {
            // Glass background
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(highlight || latest ? 0.10 : 0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: borderColors,
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: (highlight || latest) ? 1.2 : 1
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
                        
                        if highlight { pill(text: "You", colors: [.cyan.opacity(0.6), .teal.opacity(0.6)]) }
                        if latest { pill(text: "New", colors: [.yellow.opacity(0.7), .orange.opacity(0.7)]) }
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
    
    private var borderColors: [Color] {
        if latest { return [Color.orange, Color.yellow] }
        if highlight { return [Color.cyan, Color.teal] }
        return [Color.white.opacity(0.14), .clear]
    }
    
    private func pill(text: String, colors: [Color]) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 6).padding(.vertical, 3)
            .background(Capsule().fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)))
            .overlay(Capsule().stroke(.white.opacity(0.25), lineWidth: 0.5))
            .foregroundColor(.white)
    }
}

#if DEBUG
#Preview {
    let appState = AppState()
    EndGameView(gameVM: GameViewModel(appReviewService: AppReviewService()), scoreVM: ScoreViewModel(appState: appState, scoreService: ScoreService(), profileService: ProfileService()))
        .environmentObject(appState)
}
#endif

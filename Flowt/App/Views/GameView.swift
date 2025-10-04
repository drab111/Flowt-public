//
//  GameView.swift
//  Flowt
//
//  Created by Wiktor Drab on 16/09/2025.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @ObservedObject var gameVM: GameViewModel
    @ObservedObject var scoreVM: ScoreViewModel
    @ObservedObject var accountScoreVM: AccountScoreViewModel
    let onTabChange: (MainMenuTab) -> Void
    
    @State private var sheen = false
    
    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 20) {
                headerPanel
                statsPanel
                playPanel
            }
            .padding(.horizontal, 14)
            
            Spacer()
        }
        .task {
            await scoreVM.loadLeaderboard(limit: 1)
            await accountScoreVM.loadUserStats()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: false)) { sheen.toggle() }
        }
        .fullScreenCover(item: $gameVM.activePhase) { phase in
            switch phase {
            case .gameScene:
                SpriteView(scene: makeGameScene())
                    .ignoresSafeArea()
                    .statusBarHidden(true)
            case .endView:
                EndGameView(gameVM: gameVM, scoreVM: scoreVM)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .statusBarHidden(true)
            }
        }
        .onChange(of: gameVM.activePhase) { oldPhase, newPhase in
            if newPhase == nil {
                Task {
                    await scoreVM.loadLeaderboard(limit: 1)
                    await accountScoreVM.loadUserStats()
                }
            }
        }
    }
    
    // MARK: - Panels
    
    private var headerPanel: some View {
        EdgeLitContainer {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: "Flowt", subtitle: "Puzzle strategy on the water")
                    
                    Divider()
                        .overlay(LinearGradient(colors: [.white.opacity(0.0), .white.opacity(0.25), .white.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
                        .padding(.vertical, 2)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Every move shapes your rank")
                    }
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.75))
                }
                Spacer()
            }
        }
        .padding(.horizontal, 14)
    }
    
    private var statsPanel: some View {
        EdgeLitContainer {
            let userBest = accountScoreVM.bestScore ?? 0
            let top  = scoreVM.leaderboard.first?.entry.score ?? 0
            let progress = top > 0 ? min(1, CGFloat(userBest) / CGFloat(top)) : 0
            
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Quick Stats", subtitle: "Snapshot")
                
                HStack(spacing: 16) {
                    // animowany wskaźnik wyniku
                    ScoreGauge(userBest: userBest, top: top)
                        .frame(width: 150, height: 150)
                    
                    // prawa kolumna
                    VStack(spacing: 10) {
                        StatChip(icon: "crown.fill", title: "Your Best Rank", value: rankText, style: .gold)
                        StatChip(icon: "trophy.fill", title: "Global #1", value: topScoreText, style: .cyan)
                        
                        ToOneBar(progress: progress, userBest: userBest, top: top)
                            .frame(height: 28)
                            .padding(.top, 4)
                    }
                }
            }
            .overlay(alignment: .topTrailing) {
                FlowDecoration()
                    .opacity(0.15)
                    .padding(.trailing, 8)
                    .padding(.bottom, 6)
            }
        }
    }
    
    private var playPanel: some View {
        AnimatedGradientButton(title: "Play", symbol: "play.fill", gradientColors: animatedGradientButtonColors) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { gameVM.startGame() }
        }
        .accessibilityLabel("Play")
        .padding(.horizontal, 35)
    }
    
    // MARK: - Helpers
    
    private var rankText: String {
        if let rank = accountScoreVM.globalRank { return "#\(rank)" }
        return "—"
    }
    
    private var topScoreText: String {
        scoreVM.leaderboard.first.map { "\($0.entry.score)" } ?? "—"
    }
    
    private func makeGameScene() -> SKScene {
        let scene = GameScene(gameVM: gameVM, scoreVM: scoreVM, cargoFactory: LightCargoFactory(), upgradeFactory: SimpleUpgradeFactory())
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scene.scaleMode = .resizeFill
        return scene
    }
}

// MARK: - Subviews

private struct ScoreGauge: View {
    let userBest: Int
    let top: Int
    
    @State private var anim: CGFloat = 0
    
    private var target: CGFloat {
        guard top > 0 else { return 0 }
        return min(1, CGFloat(userBest) / CGFloat(top))
    }
    
    private var percentText: String {
        top > 0 ? "\(Int(target * 100))%" : "—"
    }
    
    private var statusText: String? {
        guard top > 0 else { return nil }
        return userBest >= top ? "Leader!" : nil
    }
    
    var body: some View {
        ZStack {
            // Tick ring
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 14)
            // Ticks
            ForEach(0..<40, id: \.self) { i in
                Capsule()
                    .fill(Color.white.opacity(i % 5 == 0 ? 0.35 : 0.18))
                    .frame(width: 2, height: i % 5 == 0 ? 10 : 6)
                    .offset(y: -58)
                    .rotationEffect(.degrees(Double(i) / 40.0 * 360.0))
            }
            // Progress ring
            Circle()
                .trim(from: 0, to: anim)
                .stroke(
                    AngularGradient(colors: [.cyan, .teal, .cyan], center: .center),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: .cyan.opacity(0.5), radius: 8, x: 0, y: 0)
            // Inner content
            VStack(spacing: 4) {
                Text("Your Best Score")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
                Text("\(userBest)")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundStyle(LinearGradient(colors: [.white, .cyan], startPoint: .top, endPoint: .bottom))
                Text(percentText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.8))
                
                if let status = statusText {
                    Text(status)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(Capsule().fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)))
                        .overlay(Capsule().stroke(.white.opacity(0.25), lineWidth: 0.5))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .padding(6)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) { anim = target }
        }
        .onChange(of: top) {
            withAnimation(.easeInOut(duration: 1.0)) { anim = target }
        }
        .onChange(of: userBest) {
            withAnimation(.easeInOut(duration: 1.0)) { anim = target }
        }
    }
}

private struct StatChip: View {
    enum Style { case gold, cyan }
    let icon: String
    let title: String
    let value: String
    var style: Style = .cyan
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(gradient, lineWidth: 1)
                )
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(gradient.opacity(0.45))
                        .frame(width: 28, height: 28)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.75))
                    Text(value)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(height: 46)
    }
    
    private var gradient: LinearGradient {
        switch style {
        case .gold:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
        case .cyan:
            return LinearGradient(colors: [.cyan, .teal], startPoint: .leading, endPoint: .trailing)
        }
    }
}

private struct ToOneBar: View {
    let progress: CGFloat
    let userBest: Int
    let top: Int
    @State private var anim: CGFloat = 0
    
    private var label: String {
        guard top > 0 else { return "To #1 —" }
        if userBest >= top { return "Leader!" }
        return "To #1  \(top - userBest)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.08)).frame(height: 8)
                GeometryReader { geo in
                    Capsule()
                        .fill(LinearGradient(colors: [.cyan, .teal], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(8, geo.size.width * min(anim, 1)), height: 8)
                        .shadow(color: .cyan.opacity(0.6), radius: 6)
                }
                .frame(height: 8)
            }
            .clipShape(Capsule())
            
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                Text(label)
                Spacer()
                if top > 0 {
                    Text("\(Int(min(anim,1) * 100))%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .font(.caption)
            .foregroundStyle(.white.opacity(0.75))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) { anim = progress }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 0.9)) { anim = newValue }
        }
    }
}

#Preview {
    let appState = AppState()
    let scoreService = ScoreService()
    GameView(
        gameVM: GameViewModel(),
        scoreVM: ScoreViewModel(appState: appState, scoreService: scoreService, profileService: ProfileService()),
        accountScoreVM: AccountScoreViewModel(appState: appState, scoreService: scoreService),
        onTabChange: { tab in
            appState.currentScreen = .mainMenu(tab)
        }
    )
    .environmentObject(appState)
}

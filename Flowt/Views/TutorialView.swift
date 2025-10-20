//
//  TutorialView.swift
//  Flowt
//
//  Created by Wiktor Drab on 25/08/2025.
//

import SwiftUI

struct TutorialView: View {
    @ObservedObject var tutorialVM: TutorialViewModel
    @GestureState private var dragOffset: CGFloat = 0 // The distance of user's drag gesture (auto resets to 0 when released)
    @State private var settledOffset: CGFloat = 0 // Enables smooth return if drag distance doesn't exceed threshold
    let onTabChange: (MainMenuTab) -> Void
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack {
                headerPanel
                Spacer()
                cardsPanel
                progressPanel
                Spacer()
                if tutorialVM.currentIndex == tutorialVM.pages.count - 1 { playPanel }
                Spacer(minLength: 40)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    
    // MARK: - Panels
    private var headerPanel: some View {
        EdgeLitContainer {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    SectionHeader(title: "Tutorial", subtitle: "Discover how to guide the flow")
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                            Capsule()
                                .fill(LinearGradient(colors: [.cyan, .teal], startPoint: .leading, endPoint: .trailing))
                                .frame(width: progressWidth(total: geo.size.width), height: 6)
                                .animation(.easeInOut(duration: 0.35), value: tutorialVM.currentIndex)
                        }
                    }
                    .frame(height: 6)
                    .padding(.top, 8)
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var cardsPanel: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(tutorialVM.pages, id: \.id) { page in
                    TutorialCard(page: page)
                        .frame(width: geo.size.width)
                }
            }
            .offset(x: -CGFloat(tutorialVM.currentIndex) * geo.size.width + settledOffset + dragOffset)
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: tutorialVM.currentIndex)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in // Update @GestureState during the drag gesture
                        state = value.translation.width // Horizontal drag distance in pixels from the gesture’s starting point (state is a temporary copy of dragOffset)
                    }
                    .onEnded { value in
                        let threshold = geo.size.width / 5 // Must drag at least 1/5 of the view’s width to switch to another page
                        if value.translation.width < -threshold && tutorialVM.currentIndex < tutorialVM.pages.count - 1 {
                            tutorialVM.currentIndex += 1
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        } else if value.translation.width > threshold && tutorialVM.currentIndex > 0 {
                            tutorialVM.currentIndex -= 1
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        } else { // Revert with animation if the threshold was not exceeded
                            settledOffset = value.translation.width
                            withAnimation(.spring()) { settledOffset = 0 }
                        }
                    }
            )
        }
        .frame(height: 420)
    }
    
    private var progressPanel: some View {
        HStack(spacing: 8) {
            ForEach(0..<tutorialVM.pages.count, id: \.self) { index in
                Circle()
                    .fill(index == tutorialVM.currentIndex ? Color.white : Color.gray.opacity(0.5))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.top, 16)
    }
    
    private var playPanel: some View {
        AnimatedGradientButton(title: "Start Playing", symbol: "play.fill", gradientColors: animatedGradientButtonColors) {
            onTabChange(.game)
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        .padding(.horizontal, 40)
        .transition(.opacity)
    }
    
    // MARK: - Helpers
    private func progressWidth(total: CGFloat) -> CGFloat {
        guard tutorialVM.pages.count > 1 else { return total }
        let step = total / CGFloat(tutorialVM.pages.count - 1)
        return step * CGFloat(tutorialVM.currentIndex)
    }
}

// MARK: Subviews
struct TutorialCard: View {
    let page: TutorialPage
    
    var body: some View {
        VStack(spacing: 20) {
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 260)
            
            Text(page.title)
                .font(.system(size: 22))
                .fontWeight(.bold)
                .foregroundStyle(LinearGradient(colors: [.white, .cyan], startPoint: .top, endPoint: .bottom))
                .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 3)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 8)
        .padding(.horizontal, 24)
    }
}

#if DEBUG
#Preview {
    let appState = AppState()
    return TutorialView(
        tutorialVM: TutorialViewModel(),
        onTabChange: { tab in
            appState.currentScreen = .mainMenu(tab)
        }
    )
    .environmentObject(appState)
}
#endif

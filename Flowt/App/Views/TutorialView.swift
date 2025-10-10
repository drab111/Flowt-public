//
//  TutorialView.swift
//  Flowt
//
//  Created by Wiktor Drab on 25/08/2025.
//

import SwiftUI

struct TutorialView: View {
    @ObservedObject var tutorialVM: TutorialViewModel
    @GestureState private var dragOffset: CGFloat = 0 // długość przesunięcia przez usera w trakcie gestu (sam wróci na 0 po zakończeniu)
    @State private var settledOffset: CGFloat = 0 // umożliwia płynny powrót gdy nie przekroczymy threshold
    let onTabChange: (MainMenuTab) -> Void
    
    var body: some View {
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
                    .updating($dragOffset) { value, state, _ in // podczas przeciągania aktualizujemy @GestureState
                        state = value.translation.width // ile pikseli przesunięte w osi X od początku gestu (state to tymczasowa kopia dragOffset)
                    }
                    .onEnded { value in
                        let threshold = geo.size.width / 5 // trzeba przeciągnąć min. 1/5 szerokości żeby przeskoczyć na inną stronę
                        if value.translation.width < -threshold && tutorialVM.currentIndex < tutorialVM.pages.count - 1 {
                            tutorialVM.currentIndex += 1
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        } else if value.translation.width > threshold && tutorialVM.currentIndex > 0 {
                            tutorialVM.currentIndex -= 1
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        } else { // cofamy z animacją gdy nie przekroczyliśmy progu
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

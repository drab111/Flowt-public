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
            Spacer(minLength: 20)
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(tutorialVM.pages, id: \.id) { page in
                        TutorialCard(page: page)
                            .frame(width: geometry.size.width)
                    }
                }
                .offset(x: -CGFloat(tutorialVM.currentIndex) * geometry.size.width + settledOffset + dragOffset)
                .animation(.spring(), value: tutorialVM.currentIndex)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in // podczas przeciągania aktualizujemy @GestureState
                            state = value.translation.width // ile pikseli przesunięte w osi X od początku gestu (state to tymczasowa kopia dragOffset)
                        }
                        .onEnded { value in
                            let threshold = geometry.size.width / 5 // trzeba przeciągnąć min. 1/5 szerokości żeby przeskoczyć na inną stronę
                            if value.translation.width < -threshold && tutorialVM.currentIndex < tutorialVM.pages.count - 1 {
                                tutorialVM.currentIndex += 1
                            } else if value.translation.width > threshold && tutorialVM.currentIndex > 0 {
                                tutorialVM.currentIndex -= 1
                            } else { // cofamy z animacją gdy nie przekroczyliśmy progu
                                settledOffset = value.translation.width
                                withAnimation(.spring()) { settledOffset = 0 }
                            }
                        }
                )
            }
            .frame(height: 420)
            
            HStack(spacing: 8) {
                ForEach(0..<tutorialVM.pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == tutorialVM.currentIndex ? Color.white : Color.gray.opacity(0.5))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.top, 16)
            
            Spacer()
            
            if tutorialVM.currentIndex == tutorialVM.pages.count - 1 {
                Button(action: {
                    onTabChange(.game)
                }) {
                    Text("Start Playing")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .gradientBackground()
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
            }
            
            Spacer(minLength: 40)
        }
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
                .shadow(radius: 6)
            
            Text(page.title)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
        .padding(.horizontal, 24)
    }
}

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

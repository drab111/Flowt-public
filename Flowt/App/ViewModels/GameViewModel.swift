//
//  GameViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 16/09/2025.
//

import SwiftUI

@MainActor
final class GameViewModel: ObservableObject {
    enum GamePhase: Identifiable {
        case gameScene
        case endView
        
        var id: Int {
            switch self {
            case .gameScene: return 1
            case .endView: return 2
            }
        }
    }
    
    @Published var activePhase: GamePhase?
    private var appState: AppState
    
    init(appState: AppState) { self.appState = appState }
    
    func startGame() { activePhase = .gameScene }
    
    func endGame() { activePhase = .endView }
    
    func backToMenu() { activePhase = nil }
}

//
//  GameViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 16/09/2025.
//

import StoreKit
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
    @AppStorage("gamesPlayed") var gamesPlayed: Int = 0
    
    // MARK: - Game Flow
    func startGame() { activePhase = .gameScene }
    
    func endGame() {
        activePhase = .endView
        incrementGamesPlayed()
    }
    
    func backToMenu() { activePhase = nil }
    
    // MARK: - Review Request
    private func incrementGamesPlayed() {
        gamesPlayed += 1
        if gamesPlayed == 10 { requestAppReview() }
    }
    
    private func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
    }
}

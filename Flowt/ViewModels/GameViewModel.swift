//
//  GameViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 16/09/2025.
//

import SwiftUI

final class GameViewModel: ObservableObject {
    @Published var gameStarted: Bool = false
    private var appState: AppState
    
    init(appState: AppState) { self.appState = appState }
    
    func startGame() { gameStarted = true }
}

//
//  AccountScoreViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 25/09/2025.
//

import SwiftUI

@MainActor
final class AccountScoreViewModel: ObservableObject {
    @Published var bestScore: Int?
    @Published var globalRank: Int?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let appState: AppState
    private let scoreService: ScoreServiceProtocol
    
    init(appState: AppState, scoreService: ScoreServiceProtocol) {
        self.appState = appState
        self.scoreService = scoreService
    }
    
    func loadUserStats() async {
        guard let userId = appState.currentUser?.uid else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            if let best = try await scoreService.fetchBestScore(userId: userId) {
                self.bestScore = best.score
                self.globalRank = try await scoreService.fetchRank(documentId: best.id!)
            } else {
                self.bestScore = nil
                self.globalRank = nil
            }
        } catch { errorMessage = error.localizedDescription }
    }
    
    func deleteUserScores() async {
        guard let uid = appState.currentUser?.uid else { return }
        do {
            try await scoreService.deleteScores(userId: uid)
            appState.currentUserProfile = nil
            appState.currentScreen = .signIn
        } catch { errorMessage = error.localizedDescription }
    }
}

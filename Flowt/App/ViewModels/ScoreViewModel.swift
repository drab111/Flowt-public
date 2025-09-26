//
//  ScoreViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 24/09/2025.
//

import AudioToolbox
import SwiftUI

@MainActor
final class ScoreViewModel: ObservableObject {
    @Published var score: Int?
    @Published var latestScoreId: String?
    @Published var userRank: Int?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var leaderboard: [(entry: ScoreEntry, profile: UserProfile?, isCurrentUser: Bool, isLatest: Bool)] = [] {
        didSet { if leaderboard.contains(where: { $0.isLatest }) { playSuccessSound() } }
    }
    
    
    private let appState: AppState
    private let scoreService: ScoreServiceProtocol
    private let profileService: UserProfileServiceProtocol
    private var hasSaved: Bool = false
    
    init(appState: AppState, scoreService: ScoreServiceProtocol, profileService: UserProfileServiceProtocol) {
        self.appState = appState
        self.scoreService = scoreService
        self.profileService = profileService
    }
    
    func reset() {
        leaderboard = []
        score = nil
        latestScoreId = nil
        userRank = nil
        errorMessage = nil
        hasSaved = false
    }
    
    func setScore(_ score: Int) { self.score = score }
    
    func saveAndLoadLeaderboard(limit: Int) async {
        isLoading = true
        defer { isLoading = false }
        
        guard !hasSaved, let userId = appState.currentUser?.uid, let score = score else { return }
        hasSaved = true
        
        let entry = ScoreEntry(id: nil, userId: userId, score: score)
        
        do {
            let documentId = try await scoreService.saveScore(entry)
            latestScoreId = documentId
            
            let rawScores = try await scoreService.fetchTopScores(limit: limit)
            var results: [(entry: ScoreEntry, profile: UserProfile?, isCurrentUser: Bool, isLatest: Bool)] = []
            for score in rawScores { // wyciągamy usera do którego należy wynik
                let profile = try await profileService.fetchProfile(uid: score.userId)
                let isCurrent = (score.userId == userId)
                let isLatest = (score.id == latestScoreId)
                results.append((entry: score, profile: profile, isCurrentUser: isCurrent, isLatest: isLatest))
            }
            leaderboard = results
            
            userRank = try await scoreService.fetchRank(documentId: documentId)
        } catch { errorMessage = error.localizedDescription }
    }
    
    func loadLeaderboard(limit: Int) async {
        isLoading = true
        defer { isLoading = false }
        
        reset()
        guard let userId = appState.currentUser?.uid else { return }
        
        do {
            let rawScores = try await scoreService.fetchTopScores(limit: limit)
            var results: [(entry: ScoreEntry, profile: UserProfile?, isCurrentUser: Bool, isLatest: Bool)] = []
            for score in rawScores {
                let profile = try await profileService.fetchProfile(uid: score.userId)
                let isCurrent = (score.userId == userId)
                results.append((entry: score, profile: profile, isCurrentUser: isCurrent, isLatest: false))
            }
            leaderboard = results
        } catch { errorMessage = error.localizedDescription }
    }
    
    private func playSuccessSound() { AudioServicesPlaySystemSound(1022) }
}

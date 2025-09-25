//
//  ScoreViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 24/09/2025.
//

import SwiftUI

@MainActor
final class ScoreViewModel: ObservableObject {
    @Published var score: Int?
    @Published var topScores: [(ScoreEntry, UserProfile?)] = []
    @Published var userRank: Int?
    @Published var errorMessage: String?
    
    
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
        score = nil
        topScores = []
        userRank = nil
        errorMessage = nil
        hasSaved = false
    }
    
    func setScore(_ score: Int) { self.score = score }
    
    func saveAndLoadRanking() async {
        guard !hasSaved, let user = appState.currentUser, let score = score else { return }
        hasSaved = true
        
        let entry = ScoreEntry(id: nil, userId: user.uid, score: score)
        
        do {
            let documentId = try await scoreService.saveScore(entry)
            let rawScores = try await scoreService.fetchTopScores(limit: 5)
            
            var results: [(ScoreEntry, UserProfile?)] = []
            for score in rawScores { // wyciągamy usera do którego należy wynik
                let profile = try await profileService.fetchProfile(uid: score.userId)
                results.append((score, profile))
            }
            topScores = results
            
            userRank = try await scoreService.fetchRank(documentId: documentId)
        } catch { errorMessage = error.localizedDescription }
    }
}

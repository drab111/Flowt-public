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
    @Published var latestScoreId: String?
    @Published var userRank: Int?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var leaderboard: [(entry: ScoreEntry, profile: UserProfile?, isCurrentUser: Bool, isLatest: Bool)] = [] {
        didSet { if leaderboard.contains(where: { $0.isLatest }) { playSuccessSound() } }
    }
    
    private let appState: AppState
    private let scoreService: ScoreServiceProtocol
    private let profileService: ProfileServiceProtocol
    private var hasSaved: Bool = false
    private var profileCache: [String: UserProfile] = [:]
    
    init(appState: AppState, scoreService: ScoreServiceProtocol, profileService: ProfileServiceProtocol) {
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
        profileCache = [:]
    }
    
    func setScore(_ score: Int) { self.score = score }
    
    func saveAndLoadLeaderboard(limit: Int) async {
        isLoading = true
        defer { isLoading = false }
        guard !hasSaved, let userId = appState.currentUser?.uid, let score = score else { return }
        hasSaved = true
        
        let entry = ScoreEntry(id: nil, userId: userId, score: score, createdAt: nil)
        
        do {
            let documentId = try await scoreService.saveScore(entry)
            latestScoreId = documentId
            
            guard let saved = try await scoreService.fetchScore(id: documentId), let createdAt = saved.createdAt else {
                 // jeśli brak stempla to próbujemy jeszcze raz po chwili
                 try? await Task.sleep(nanoseconds: 200_000_000)
                 if let retry = try await scoreService.fetchScore(id: documentId), let createdAtRetry = retry.createdAt {
                     userRank = try await scoreService.fetchRank(score: retry.score, createdAt: createdAtRetry)
                 }
                 try await loadLeaderboardInternal(limit: limit, highlightLatestId: documentId)
                 return
             }
             userRank = try await scoreService.fetchRank(score: saved.score, createdAt: createdAt)
             try await loadLeaderboardInternal(limit: limit, highlightLatestId: documentId)
        } catch { errorMessage = error.localizedDescription }
    }
    
    func loadLeaderboard(limit: Int) async {
        isLoading = true
        defer { isLoading = false }
        reset()
        do {
            try await loadLeaderboardInternal(limit: limit, highlightLatestId: nil)
        } catch { errorMessage = error.localizedDescription }
    }
    
    private func loadLeaderboardInternal(limit: Int, highlightLatestId: String?) async throws {
        guard let userId = appState.currentUser?.uid else { return }
        let rawScores = try await scoreService.fetchTopScores(limit: limit)

        // Równoległe pobieranie profili + prosty cache, aby nie powielać odczytów
        let uniqueUserIds = Array(Set(rawScores.map { $0.userId }))
        try await withThrowingTaskGroup(of: (String, UserProfile?).self) { group in
            for uid in uniqueUserIds where profileCache[uid] == nil {
                group.addTask { [profileService] in
                    let profile = try? await profileService.fetchProfile(uid: uid)
                    return (uid, profile)
                }
            }
            for try await (uid, profile) in group {
                if let profile { profileCache[uid] = profile }
            }
        }

        let mapped = rawScores.map { scoreEntry in
            let profile = profileCache[scoreEntry.userId] ?? nil
            let isCurrent = (scoreEntry.userId == userId)
            let isLatest  = (scoreEntry.id == highlightLatestId)
            return (entry: scoreEntry, profile: profile, isCurrentUser: isCurrent, isLatest: isLatest)
        }

        leaderboard = mapped
    }
    
    func makeSharePayload() -> ScoreSharePayload? {
        let score = self.score ?? 0
        let rank = self.userRank

        let card = ScoreShareCardView(score: score, rank: rank, nickname: appState.currentUserProfile?.nickname)
            .frame(width: 600, height: 320)

        // renderujemy do PNG
        let renderer = ImageRenderer(content: card)
        renderer.scale = 2.0

        guard let uiImage = renderer.uiImage, let png = uiImage.pngData() else { return nil }

        return ScoreSharePayload(imageData: png)
    }
    
    private func playSuccessSound() { AudioService.shared.playSystemSFX(id: 1022) }
}

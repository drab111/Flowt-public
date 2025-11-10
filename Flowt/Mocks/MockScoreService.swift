#if DEBUG

//
//  MockScoreService.swift
//  Flowt
//
//  Created by Wiktor Drab on 07/11/2025.
//

import Foundation

final class MockScoreService: ScoreServiceProtocol {
    var scores: [String: ScoreEntry] = [:]
    var lastSavedScore: ScoreEntry?
    var lastDeletedUserId: String?
    var shouldThrowOnSave: Bool = false
    var shouldThrowOnFetchTopScores: Bool = false
    var shouldThrowOnFetchRank: Bool = false
    var shouldThrowOnFetchBestScore: Bool = false
    var shouldThrowOnFetchScore: Bool = false
    var shouldThrowOnDelete: Bool = false
    
    var thrownError: Error = NSError(domain: "MockScoreService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
    
    init() {
        let env = ProcessInfo.processInfo.environment
        if env["MOCK_SCORE_SHOULD_THROW_SAVE"] == "1" { shouldThrowOnSave = true }
        if env["MOCK_SCORE_SHOULD_THROW_FETCH_TOP_SCORES"] == "1" { shouldThrowOnFetchTopScores = true }
        if env["MOCK_SCORE_SHOULD_THROW_FETCH_RANK"] == "1" { shouldThrowOnFetchRank = true }
        if env["MOCK_SCORE_SHOULD_THROW_FETCH_BEST_SCORE"] == "1" { shouldThrowOnFetchBestScore = true }
        if env["MOCK_SCORE_SHOULD_THROW_FETCH_SCORE"] == "1" { shouldThrowOnFetchScore = true }
        if env["MOCK_SCORE_SHOULD_THROW_DELETE"] == "1" { shouldThrowOnDelete = true }
    }
    
    // MARK: - Create & Save
    func saveScore(_ entry: ScoreEntry) async throws -> String {
        if shouldThrowOnSave { throw thrownError }
        
        var saved = entry
        let id = entry.id ?? UUID().uuidString // generate fake ID if missing
        saved = ScoreEntry(id: id, userId: entry.userId, score: entry.score, createdAt: entry.createdAt ?? Date())
        scores[id] = saved
        lastSavedScore = saved
        return id
    }
    
    // MARK: - Fetching
    func fetchTopScores(limit: Int) async throws -> [ScoreEntry] {
        if shouldThrowOnFetchTopScores { throw thrownError }
        
        return Array(scores.values.sorted {
                if $0.score == $1.score {
                    // earlier createdAt first if same score
                    return ($0.createdAt ?? Date.distantFuture) < ($1.createdAt ?? Date.distantFuture)
                }
                return $0.score > $1.score
            }
            .prefix(limit))
    }
    
    func fetchRank(score: Int, createdAt: Date) async throws -> Int {
        if shouldThrowOnFetchRank { throw thrownError }
        
        let higher = scores.values.filter { $0.score > score }.count
        let tieEarlier = scores.values.filter { $0.score == score && ($0.createdAt ?? Date.distantFuture) < createdAt }.count
        return higher + tieEarlier + 1
    }
    
    func fetchBestScore(userId: String) async throws -> ScoreEntry? {
        if shouldThrowOnFetchBestScore { throw thrownError }
        
        return scores.values.filter { $0.userId == userId }
            .sorted {
                if $0.score == $1.score {
                    return ($0.createdAt ?? Date.distantFuture) < ($1.createdAt ?? Date.distantFuture)
                }
                return $0.score > $1.score
            }
            .first
    }
    
    func fetchScore(id: String) async throws -> ScoreEntry? {
        if shouldThrowOnFetchScore { throw thrownError }
        return scores[id]
    }
    
    // MARK: - Deletion
    func deleteScores(userId: String) async throws {
        if shouldThrowOnDelete { throw thrownError }
        
        scores = scores.filter { $0.value.userId != userId }
        lastDeletedUserId = userId
    }
}

#endif

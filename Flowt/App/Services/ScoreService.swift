//
//  ScoreService.swift
//  Flowt
//
//  Created by Wiktor Drab on 24/09/2025.
//

import FirebaseFirestore

protocol ScoreServiceProtocol {
    func saveScore(_ entry: ScoreEntry) async throws -> String
    func fetchTopScores(limit: Int) async throws -> [ScoreEntry]
    func fetchRank(documentId: String) async throws -> Int?
    func fetchBestScore(userId: String) async throws -> ScoreEntry?
    func deleteScores(userId: String) async throws
}

final class ScoreService: ScoreServiceProtocol {
    private let db = Firestore.firestore()
    
    func saveScore(_ entry: ScoreEntry) async throws -> String {
        let data: [String: Any] = [
            "userId": entry.userId,
            "score": entry.score
        ]
        
        let ref = try await db.collection("scores").addDocument(data: data)
        return ref.documentID
    }
    
    func fetchTopScores(limit: Int) async throws -> [ScoreEntry] {
        let snapshot = try await db.collection("scores")
            .order(by: "score", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.map { doc in
            ScoreEntry(
                id: doc.documentID,
                userId: doc["userId"] as? String ?? "",
                score: doc["score"] as? Int ?? 0
            )
        }
    }
    
    func fetchRank(documentId: String) async throws -> Int? {
        let snapshot = try await db.collection("scores")
            .order(by: "score", descending: true)
            .getDocuments()
        
        if let index = snapshot.documents.firstIndex(where: { $0.documentID == documentId }) { return index + 1 }
        return nil
    }
    
    func fetchBestScore(userId: String) async throws -> ScoreEntry? {
        let snapshot = try await db.collection("scores")
            .whereField("userId", isEqualTo: userId)
            .order(by: "score", descending: true)
            .limit(to: 1)
            .getDocuments()
        
        guard let doc = snapshot.documents.first else { return nil }
        return ScoreEntry(
            id: doc.documentID,
            userId: doc["userId"] as? String ?? "",
            score: doc["score"] as? Int ?? 0
        )
    }
    
    func deleteScores(userId: String) async throws {
        let snapshot = try await db.collection("scores")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        let batch = db.batch()
        for doc in snapshot.documents { batch.deleteDocument(doc.reference) }
        try await batch.commit()
    }
}

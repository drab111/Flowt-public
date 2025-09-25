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
}

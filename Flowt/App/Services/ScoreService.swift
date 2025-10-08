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
    func fetchRank(score: Int, createdAt: Date) async throws -> Int
    func fetchBestScore(userId: String) async throws -> ScoreEntry?
    func fetchScore(id: String) async throws -> ScoreEntry?
    func deleteScores(userId: String) async throws
}

final class ScoreService: ScoreServiceProtocol {
    private let db = Firestore.firestore()
    
    func saveScore(_ entry: ScoreEntry) async throws -> String {
        let data: [String: Any] = [
            "userId": entry.userId,
            "score": entry.score,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        let ref = try await db.collection("scores").addDocument(data: data)
        return ref.documentID
    }
    
    func fetchTopScores(limit: Int) async throws -> [ScoreEntry] {
        let snapshot = try await db.collection("scores")
            .order(by: "score", descending: true)
            .order(by: "createdAt", descending: false)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.map { doc in
            ScoreEntry(
                id: doc.documentID,
                userId: doc["userId"] as? String ?? "",
                score: doc["score"] as? Int ?? 0,
                createdAt: (doc["createdAt"] as? Timestamp)?.dateValue()
            )
        }
    }
    
    func fetchRank(score: Int, createdAt: Date) async throws -> Int {
        // konwersja Date -> Timestamp dla zapytania
        let ts = Timestamp(date: createdAt)

        // ile osób ma wyższy wynik
        let greaterQ = db.collection("scores")
            .whereField("score", isGreaterThan: score)
        let greaterAgg = try await greaterQ.count.getAggregation(source: .server)
        let greater = greaterAgg.count.intValue

        // ile osób ma ten sam wynik ale wcześniejszy czas
        let tieQ = db.collection("scores")
            .whereField("score", isEqualTo: score)
            .whereField("createdAt", isLessThan: ts)
        let tieAgg = try await tieQ.count.getAggregation(source: .server)
        let ties = tieAgg.count.intValue

        return greater + ties + 1
    }
    
    func fetchBestScore(userId: String) async throws -> ScoreEntry? {
        let snapshot = try await db.collection("scores")
            .whereField("userId", isEqualTo: userId)
            .order(by: "score", descending: true)
            .order(by: "createdAt", descending: false)
            .limit(to: 1)
            .getDocuments()
        
        guard let doc = snapshot.documents.first else { return nil }
        return ScoreEntry(
            id: doc.documentID,
            userId: doc["userId"] as? String ?? "",
            score: doc["score"] as? Int ?? 0,
            createdAt: (doc["createdAt"] as? Timestamp)?.dateValue()
        )
    }
    
    func fetchScore(id: String) async throws -> ScoreEntry? {
        let doc = try await db.collection("scores").document(id).getDocument()
        guard let data = doc.data() else { return nil }
        return ScoreEntry(
            id: doc.documentID,
            userId: data["userId"] as? String ?? "",
            score: data["score"] as? Int ?? 0,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue()
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

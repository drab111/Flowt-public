//
//  ScoreEntry.swift
//  Flowt
//
//  Created by Wiktor Drab on 24/09/2025.
//

struct ScoreEntry: Identifiable, Codable {
    var id: String? // docId w Firestore
    var userId: String
    var score: Int
}

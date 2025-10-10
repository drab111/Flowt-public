//
//  ScoreEntry.swift
//  Flowt
//
//  Created by Wiktor Drab on 24/09/2025.
//

import Foundation

struct ScoreEntry: Identifiable, Codable {
    var id: String? // docId in Firestore
    var userId: String
    var score: Int
    var createdAt: Date?
}

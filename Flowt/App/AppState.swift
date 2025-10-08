//
//  AppState.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/08/2025.
//

import SwiftUI
import FirebaseAuth

enum Screen: Equatable {
    case loading, signIn, verifyEmail, mainMenu(MainMenuTab)
}

enum MainMenuTab: CaseIterable, Equatable {
    case profile, tutorial, game, leaderboard, info
    
    var title: String {
        switch self {
        case .profile: return "Profile"
        case .tutorial: return "Tutorial"
        case .game: return "Game"
        case .leaderboard: return "Ranks"
        case .info: return "Info"
        }
    }
    
    var icon: String {
        switch self {
        case .profile: return "gearshape"
        case .tutorial: return "book"
        case .game: return "gamecontroller"
        case .leaderboard: return "list.star"
        case .info: return "info"
        }
    }
}

@MainActor
class AppState: ObservableObject {
    @Published var currentScreen: Screen = .loading
    @Published var currentUser: AuthUser? = nil
    @Published var currentUserProfile: UserProfile? = nil {
        didSet {
            if let profile = currentUserProfile {
                NotificationCenter.default.post(name: .userPreferencesChanged, object: profile)
            }
        }
    }
    
    init() { checkUserSession() }
    
    func checkUserSession() {
        if let user = Auth.auth().currentUser {
            Task {
                do {
                    try await user.reload()
                    let newUser = AuthUser(uid: user.uid, displayName: user.displayName, email: user.email)
                    if currentUser != newUser { currentUser = newUser }
                    
                    let newScreen: Screen = user.isEmailVerified ? .mainMenu(.profile) : .verifyEmail
                    if currentScreen != newScreen { currentScreen = newScreen }
                } catch {
                    if currentScreen != .signIn { currentScreen = .signIn }
                }
            }
        } else {
            if currentScreen != .signIn { currentScreen = .signIn }
        }
    }
}

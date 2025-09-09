//
//  AppState.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/08/2025.
//

import SwiftUI
import FirebaseAuth

enum Screen {
    case loading, signIn, verifyEmail, mainMenu(MainMenuTab)
}

enum MainMenuTab: CaseIterable {
    case account, tutorial, game, ranking, settings
    
    var title: String {
        switch self {
        case .account: return "Account"
        case .tutorial: return "Tutorial"
        case .game: return "Game"
        case .ranking: return "Ranking"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .account: return "person.circle"
        case .tutorial: return "book.fill"
        case .game: return "gamecontroller"
        case .ranking: return "list.bullet"
        case .settings: return "gearshape"
        }
    }
}

@MainActor
class AppState: ObservableObject {
    @Published var currentScreen: Screen = .loading
    @Published var currentUser: AuthUser? = nil
    @Published var currentUserProfile: UserProfile? = nil
    
    init() { checkUserSession() }
    
    func checkUserSession() {
        Task {
            if let user = Auth.auth().currentUser {
                do {
                    try await user.reload()
                    currentUser = AuthUser(uid: user.uid, displayName: user.displayName, email: user.email)
                    if user.isEmailVerified {
                        currentScreen = .mainMenu(.account)
                    } else {
                        currentScreen = .verifyEmail
                    }
                } catch { currentScreen = .signIn }
            } else {
                currentScreen = .signIn
            }
        }
    }
}

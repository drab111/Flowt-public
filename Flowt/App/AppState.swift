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

enum MainMenuTab {
    case account, tutorial, game, ranking, settings
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

//
//  AppState.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/08/2025.
//

import SwiftUI
import FirebaseAuth

@MainActor
class AppState: ObservableObject {
    enum Screen {
        case signIn, verifyEmail, mainMenu, account
    }
    
    @Published var currentScreen: Screen = .signIn
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
                        currentScreen = .mainMenu
                    } else {
                        currentScreen = .verifyEmail
                    }
                } catch { currentScreen = .signIn }
            } else {
                currentScreen = .signIn
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            currentUserProfile = nil
            currentScreen = .signIn
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

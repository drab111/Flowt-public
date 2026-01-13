//
//  AppState.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/08/2025.
//

import SwiftUI

@MainActor
class AppState: ObservableObject {
    private let authSession: AuthSession
    @Published var currentScreen: Screen = .loading
    @Published var currentUser: AuthUser? = nil
    @Published var currentUserProfile: UserProfile? = nil
    
    init(authSession: AuthSession? = nil) {
        let env = ProcessInfo.processInfo.environment
        
        if let provided = authSession {
            self.authSession = provided
        } else {
            #if DEBUG
            if env["USE_MOCK_SERVICES"] == "1" {
                self.authSession = MockAuthSession()
            } else { self.authSession = FirebaseAuthSession() }
            #else
            self.authSession = FirebaseAuthSession()
            #endif
        }
        
        guard let mode = env["SKIP_LOGIN"], mode != "0" else {
            // standard route
            checkUserSession()
            return
        }
        
        // for UI tests
        let mockUid = "ui-test-uid"
        currentUser = AuthUser(uid: mockUid, displayName: "UI Tester", email: "ui-test@example.com")
        currentUserProfile = UserProfile(id: mockUid, nickname: "UI Tester", avatarBase64: env["PRELOAD_AVATAR_BASE64"], musicEnabled: true, sfxEnabled: true)
        currentScreen = (mode == "2") ? .verifyEmail : .mainMenu(.profile)
    }
    
    func checkUserSession() {
        if let user = authSession.currentUser {
            Task {
                do {
                    try await authSession.reload(user)
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

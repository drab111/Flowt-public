//
//  FlowtApp.swift
//  Flowt
//
//  Created by Wiktor Drab on 20/08/2025.
//

import SwiftUI
import FirebaseCore

@main
struct FlowtApp: App {
    @StateObject private var appState: AppState
    
    init() {
        if ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] != "1" { FirebaseApp.configure() }
        if ProcessInfo.processInfo.environment["SKIP_TERMS_AGREEMENT"] == "0" {
            UserDefaults.standard.set(false, forKey: "hasAcceptedTerms")
        } else if ProcessInfo.processInfo.environment["SKIP_TERMS_AGREEMENT"] == "1" {
            UserDefaults.standard.set(true, forKey: "hasAcceptedTerms")
        }
        
        let appState = AppState()
        // Assign object directly to the wrapper instead of the variable
        _appState = StateObject(wrappedValue: appState)
        GameCenterService.shared.authenticate()
        _ = AudioService.shared // Trigger initialization to set up the observer
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(appState: appState)
                .preferredColorScheme(.dark)
        }
    }
}

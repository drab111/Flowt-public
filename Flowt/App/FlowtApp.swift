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
        FirebaseApp.configure()
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

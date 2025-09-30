//
//  AudioViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 26/09/2025.
//

import SwiftUI

@MainActor
final class AudioViewModel: ObservableObject {
    private var service: AudioServiceProtocol

    init(service: AudioServiceProtocol) {
        self.service = service
        
        // Obserwujemy zmiany w AppState
        NotificationCenter.default.addObserver(forName: .userPreferencesChanged, object: nil, queue: .main) { [weak self] notification in
            guard let profile = notification.object as? UserProfile else { return }
            Task { @MainActor in
                self?.applyPreferences(profile: profile)
            }
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }
    
    func applyPreferences(profile: UserProfile) {
        service.sfxEnabled = profile.sfxEnabled
        service.musicEnabled = profile.musicEnabled
        
        if profile.musicEnabled {
            if !service.hasPlayer { service.start() }
        } else {
            if service.hasPlayer { service.stop() }
        }
    }
}

//
//  AudioViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 26/09/2025.
//

import SwiftUI

@MainActor
final class AudioViewModel: ObservableObject {
    private let service: AudioServiceProtocol
    @Published var isPlaying = false // przyda sie do SettingsView
    
    init(service: AudioServiceProtocol) { self.service = service }
    
    func start() {
        service.start()
        isPlaying = true
    }
    
    func stop() {
        service.stop()
        isPlaying = false
    }
    
    func pause() {
        service.pause()
        isPlaying = false
    }
    
    func resume() {
        service.resume()
        isPlaying = true
    }
}

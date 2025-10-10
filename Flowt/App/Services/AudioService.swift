//
//  AudioService.swift
//  Flowt
//
//  Created by Wiktor Drab on 26/09/2025.
//

import AudioToolbox
import AVFoundation
import SpriteKit

protocol AudioServiceProtocol {
    func start()
    func stop()
    var hasPlayer: Bool { get }
    var musicEnabled: Bool { get set }
    var sfxEnabled: Bool { get set }
}

final class AudioService: AudioServiceProtocol {
    static let shared = AudioService() // Singleton
    
    private var endObserver: Any?
    private var preferencesObserver: Any?
    private var player: AVPlayer?
    private var trackNames = ["track1", "track2", "track3"]
    private var currentIndex = 0
    
    var hasPlayer: Bool { return player != nil }
    var musicEnabled: Bool = true
    var sfxEnabled: Bool = true
    
    private init() {
        preferencesObserver = NotificationCenter.default.addObserver(forName: .userPreferencesChanged, object: nil, queue: .main) { [weak self] notification in
            guard let profile = notification.object as? UserProfile else { return }
            Task { @MainActor in
                self?.applyPreferences(profile: profile)
            }
        }
    }
    
    deinit {
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
        if let preferencesObserver { NotificationCenter.default.removeObserver(preferencesObserver) }
    }
    
    // MARK: - Preference Handling
    private func applyPreferences(profile: UserProfile) {
        sfxEnabled = profile.sfxEnabled
        musicEnabled = profile.musicEnabled
        
        if profile.musicEnabled {
            if !hasPlayer { start() }
        } else {
            if hasPlayer { stop() }
        }
    }
    
    // MARK: - Music Playback
    func start() {
        guard musicEnabled, player == nil else { return }
        
        // Shuffle the playlist
        trackNames.shuffle()
        currentIndex = 0
        playTrack(index: currentIndex)
    }
    
    private func playTrack(index: Int) {
        guard musicEnabled else { return }
        guard index < trackNames.count else {
            currentIndex = 0 // Restart from the beginning when reaching the end
            playTrack(index: currentIndex)
            return
        }
        
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
        
        guard let url = Bundle.main.url(forResource: trackNames[index], withExtension: "mp3") else { return }
        
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.volume = 0.5
        player?.play()
        
        // Observe when the audio track finishes playing in order to play the next track
        endObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.currentIndex += 1
            self.playTrack(index: self.currentIndex)
        }
    }
    
    func stop() {
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
        endObserver = nil
        player?.pause()
        player = nil
    }
    
    // MARK: - Sound Effects
    func playSFX(node: SKNode, fileName: String) {
        guard sfxEnabled else { return }
        node.run(SKAction.playSoundFileNamed(fileName, waitForCompletion: false))
    }
    
    func playSystemSFX(id: SystemSoundID) {
        guard sfxEnabled else { return }
        AudioServicesPlaySystemSound(id)
    }
    
    func playEndGameSound() async {
        guard sfxEnabled, let url = Bundle.main.url(forResource: "explodeSound", withExtension: "wav") else { return }
        stop()
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let item = AVPlayerItem(url: url)
        let soundPlayer = AVPlayer(playerItem: item)
        player = soundPlayer
        soundPlayer.volume = 0.8
        soundPlayer.play()
        
        // Observe when the audio track finishes playing
        for await _ in NotificationCenter.default.notifications(named: .AVPlayerItemDidPlayToEndTime, object: item) {
            break // First event is enough
        }
        player = nil
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        start()
    }
}

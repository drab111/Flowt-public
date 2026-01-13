//
//  AudioService.swift
//  Flowt
//
//  Created by Wiktor Drab on 26/09/2025.
//

import AudioToolbox
import AVFoundation
import Combine
import SpriteKit

protocol AudioServiceProtocol {
    func start()
    func stop()
    var musicEnabled: Bool { get set }
    var sfxEnabled: Bool { get set }
}

final class AudioService: AudioServiceProtocol {
    static let shared = AudioService()
    
    private var preferenceCancellables = Set<AnyCancellable>()
    private var playbackCancellables = Set<AnyCancellable>()
    
    private var player: AVPlayer?
    private var trackNames = ["track1", "track2", "track3"]
    private var currentIndex = 0
    
    var musicEnabled: Bool = true
    var sfxEnabled: Bool = true
    
    private init() {}
    
    func bind(_ userProfilePublisher: AnyPublisher<UserProfile?, Never>) {
        guard ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] != "1" else { return }
        preferenceCancellables.removeAll()
        
        userProfilePublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                self?.applyPreferences(profile: profile)
            }
            .store(in: &preferenceCancellables)
    }

    
    // MARK: - Preference Handling
    private func applyPreferences(profile: UserProfile) {
        sfxEnabled = profile.sfxEnabled
        musicEnabled = profile.musicEnabled
        
        if profile.musicEnabled {
            start()
        } else { stop() }
    }
    
    // MARK: - Music Playback
    func start() {
        guard ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] != "1" else { return }
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
        
        guard let url = Bundle.main.url(forResource: trackNames[index], withExtension: "mp3") else { return }
        
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.volume = 0.5
        player?.play()
        
        // Observe when the audio track finishes playing in order to play the next track
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
            .prefix(1) // automatically ends the subscription after the first event
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.playbackCancellables.removeAll()
                self.currentIndex += 1
                self.playTrack(index: self.currentIndex)
            }
            .store(in: &playbackCancellables)
    }
    
    func stop() {
        playbackCancellables.removeAll()
        player?.pause()
        player = nil
    }
    
    // MARK: - Sound Effects
    func playSFX(node: SKNode, fileName: String) {
        guard ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] != "1" else { return }
        guard sfxEnabled else { return }
        node.run(SKAction.playSoundFileNamed(fileName, waitForCompletion: false))
    }
    
    func playSystemSFX(id: SystemSoundID) {
        guard ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] != "1" else { return }
        guard sfxEnabled else { return }
        AudioServicesPlaySystemSound(id)
    }
    
    func playEndGameSound() async {
        guard ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] != "1" else { return }
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
            break // first event is enough
        }
        player = nil
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        start()
    }
}

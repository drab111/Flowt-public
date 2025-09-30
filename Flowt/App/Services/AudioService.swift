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
    static let shared = AudioService()
    
    private var endObserver: Any?
    private var player: AVPlayer?
    private var trackNames = ["track1", "track2", "track3", "track4"]
    private var currentIndex = 0
    
    var hasPlayer: Bool { return player != nil }
    var musicEnabled: Bool = true
    var sfxEnabled: Bool = true
    
    private init() {}
    
    deinit { if let endObserver { NotificationCenter.default.removeObserver(endObserver) } }
    
    // MARK: - Music
    
    func start() {
        guard musicEnabled, player == nil else { return }
        
        // Losujemy playlistę
        trackNames.shuffle()
        currentIndex = 0
        playTrack(index: currentIndex)
    }
    
    private func playTrack(index: Int) {
        guard musicEnabled else { return }
        guard index < trackNames.count else {
            currentIndex = 0 // Jeśli dojdziemy do końca to zaczynamy od nowa
            playTrack(index: currentIndex)
            return
        }
        
        guard let url = Bundle.main.url(forResource: trackNames[index], withExtension: "mp3") else { return }
        
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.volume = 0.5
        player?.play()
        
        // Obserwujemy koniec utworu
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
    
    // MARK: - SFX
    
    func playSFX(node: SKNode, fileName: String) {
        guard sfxEnabled else { return }
        node.run(SKAction.playSoundFileNamed(fileName, waitForCompletion: false))
    }
    
    func playSystemSFX(id: SystemSoundID) {
        guard sfxEnabled else { return }
        AudioServicesPlaySystemSound(id)
    }
}

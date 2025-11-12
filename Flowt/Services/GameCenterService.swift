//
//  GameCenterService.swift
//  Flowt
//
//  Created by Wiktor Drab on 14/10/2025.
//

import GameKit

@MainActor
final class GameCenterService {
    static let shared = GameCenterService()
    var displayName: String? { GKLocalPlayer.local.isAuthenticated ? GKLocalPlayer.local.displayName : nil }
    private init() {}

    // MARK: - Authentication
    func authenticate() {
        guard ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] != "1" else { return }
        let player = GKLocalPlayer.local
        player.authenticateHandler = { [weak self] vc, error in
            if let vc = vc {
                self?.presentOnTop(vc) // system login screen
                return
            }
        }
    }
    
    // MARK: - Report Achievements
    func unlockAchievement(id: String) {
        guard ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] != "1" else { return }
        guard GKLocalPlayer.local.isAuthenticated else { return }

        let achievement = GKAchievement(identifier: id)
        achievement.percentComplete = 100.0
        achievement.showsCompletionBanner = true

        GKAchievement.report([achievement])
    }

    // MARK: - Helper
    private func presentOnTop(_ vc: UIViewController) {
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else { return }
        var top = root
        while let presented = top.presentedViewController { top = presented }
        top.present(vc, animated: true)
    }
}

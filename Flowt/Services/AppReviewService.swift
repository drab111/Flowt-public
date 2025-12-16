//
//  AppReviewService.swift
//  Flowt
//
//  Created by Wiktor Drab on 13/12/2025.
//

import StoreKit

@MainActor
protocol AppReviewServiceProtocol {
    func requestAppReview()
}

@MainActor
final class AppReviewService: AppReviewServiceProtocol {
    func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
    }
}

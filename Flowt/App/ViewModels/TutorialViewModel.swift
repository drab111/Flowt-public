//
//  TutorialViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 25/09/2025.
//

import SwiftUI

@MainActor
final class TutorialViewModel: ObservableObject {
    @Published var currentIndex = 0
    let pages: [TutorialPage] = [
        TutorialPage(imageName: "FlowtLogo", title: "Welcome!", description: "Guide your ships between ports and deliver cargo."),
        TutorialPage(imageName: "FlowtLogo", title: "Ports", description: "Ports receive cargo. Connect them with routes of matching colors."),
        TutorialPage(imageName: "FlowtLogo", title: "Storms", description: "Avoid storms! Routes through them will break."),
        TutorialPage(imageName: "FlowtLogo", title: "Upgrades", description: "Earn upgrades as you score higher."),
    ]
    
    func nextPage() {
        if currentIndex < pages.count - 1 { currentIndex += 1 }
    }
    
    func prevPage() {
        if currentIndex > 0 { currentIndex -= 1 }
    }
}

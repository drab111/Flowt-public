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
        TutorialPage(imageName: "FlowtLogo", title: "Welcome to Flowt", description: "Guide your ships between offshore platforms to deliver vital resources. Plan routes wisely, balance supply and demand, and keep the system running."),
        
        TutorialPage(imageName: "TutorialCargo", title: "Cargo Types", description: "There are three types of cargo: Oil, Gas, and Food. Each has its own symbol. Platforms continuously generate cargo that must be transported before they overflow."),
        
        TutorialPage(imageName: "TutorialPlatform", title: "Platforms", description: "Every platform has a symbol showing what type of cargo it accepts. At the same time, it produces the other two types, creating a constant flow of resources. New platforms appear on the map over time, gradually increasing the challenge."),
        
        TutorialPage(imageName: "TutorialOverload", title: "Overload Risk", description: "A platform can store up to 5 cargo units. If it exceeds this limit, a 30-second timer begins. Failing to clear the platform in time will end the game."),
        
        TutorialPage(imageName: "TutorialShip", title: "Ships", description: "Ships have limited capacity (starting at 4 units). They collect produced cargo and deliver it to platforms that require it. Each successful delivery awards points."),
        
        TutorialPage(imageName: "TutorialLineBasic", title: "Lines", description: "Draw lines to connect platforms. Ships travel along these routes, automatically picking up and dropping off cargo. Once a line segment is placed, it cannot be removed, so plan carefully."),
        
        TutorialPage(imageName: "TutorialLineExtensions", title: "Extending Lines", description: "You can extend a line by adding platforms at its start or end, or by closing it into a loop. Balanced routes ensure efficient cargo flow and prevent overloads."),
        
        TutorialPage(imageName: "TutorialExtraLines", title: "Additional Lines", description: "During the game, you will unlock extra lines. Each new line comes with its own ship, giving you more flexibility to manage cargo distribution."),
        
        TutorialPage(imageName: "TutorialIsland", title: "Islands", description: "Lines cannot cross islands. Any attempt to draw a route through land will be rejected."),
        
        TutorialPage(imageName: "TutorialStorm", title: "Storms", description: "Storms appear periodically at random locations. Ships move slower inside storm zones, so adapt your strategy to avoid bottlenecks."),
        
        TutorialPage(imageName: "TutorialUpgrade", title: "Upgrades", description: "At intervals, you can choose an upgrade: a new ship, faster ships, or increased capacity. Each upgrade must be assigned to one of your lines."),
        
        TutorialPage(imageName: "TutorialRanking", title: "Aim for the Top", description: "Deliver as much cargo as possible and survive as long as you can. Strive for the highest score and climb the global ranking.")
    ]
    
    func nextPage() {
        if currentIndex < pages.count - 1 { currentIndex += 1 }
    }
    
    func prevPage() {
        if currentIndex > 0 { currentIndex -= 1 }
    }
}

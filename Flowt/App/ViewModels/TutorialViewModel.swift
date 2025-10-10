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
    
    // MARK: - Tutorial Pages
    let pages: [TutorialPage] = [
        TutorialPage(imageName: "FlowtLogo", title: "Welcome to Flowt", description: "Guide your ships between offshore platforms to deliver vital resources. Plan routes wisely, balance supply and demand, and keep the system running."),
        
        TutorialPage(imageName: "TutorialCargo", title: "Cargo Types", description: "There are three types of cargo: Oil, Gas, and Food. Each has its own symbol. Platforms continuously generate cargo that must be transported before they overflow."),
        
        TutorialPage(imageName: "TutorialPlatform", title: "Platforms", description: "Each platform displays the cargo type it accepts and continuously produces the other two. New platforms spawn during the game, gradually expanding the network."),
        
        TutorialPage(imageName: "TutorialOverload", title: "Overload Risk", description: "A platform can store up to 5 cargo units. If it exceeds this limit, a 30-second timer begins. Failing to clear the platform in time will end the game."),
        
        TutorialPage(imageName: "TutorialShip", title: "Ships", description: "Ships have limited capacity (starting at 4 units). They collect produced cargo and deliver it to platforms that require it. Each successful delivery awards points."),
        
        TutorialPage(imageName: "TutorialLineBasic", title: "Lines", description: "Draw lines to connect platforms. Ships travel along these routes, automatically picking up and dropping off cargo. Once a line segment is placed, it cannot be removed, so plan carefully."),
        
        TutorialPage(imageName: "TutorialLineExtension", title: "Extending Lines", description: "You can extend a line by adding platforms at its start or end, or by closing it into a loop. Balanced routes ensure efficient cargo flow and prevent overloads."),
        
        TutorialPage(imageName: "TutorialExtraLines", title: "Additional Lines", description: "During the game, you will unlock extra lines. Each new line comes with its own ship, giving you more flexibility to manage cargo distribution."),
        
        TutorialPage(imageName: "TutorialIsland", title: "Islands", description: "Lines cannot cross islands. Any attempt to draw a route through land will be rejected."),
        
        TutorialPage(imageName: "TutorialStorm", title: "Storms", description: "Storms appear at random locations on the map. Ships entering a storm zone move slower, which can delay deliveries."),
        
        TutorialPage(imageName: "TutorialUpgrade", title: "Upgrades", description: "At intervals, you can choose an upgrade: a new ship, faster ships, or increased capacity. Each upgrade must be assigned to one of your lines."),
        
        TutorialPage(imageName: "FlowtLogo", title: "Aim for the Top", description: "Deliver as much cargo as possible and survive as long as you can. Strive for the highest score and climb the global ranking.")
    ]
    
    // MARK: - Navigation
    func nextPage() {
        if currentIndex < pages.count - 1 { currentIndex += 1 }
    }
    
    func prevPage() {
        if currentIndex > 0 { currentIndex -= 1 }
    }
}

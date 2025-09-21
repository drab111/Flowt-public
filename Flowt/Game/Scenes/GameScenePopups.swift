//
//  GameScenePopups.swift
//  Flowt
//
//  Created by Wiktor Drab on 20/09/2025.
//

import SpriteKit

extension GameScene {
    private func presentPopup(_ popup: SKNode) {
        guard activePopup == nil else { return }
        addChild(popup)
        activePopup = popup
    }
    
    func showUpgradePopup() {
        let popup = UpgradePopup(size: self.size) { [weak self] option in
            guard let self = self else { return }
            //self.run(SKAction.playSoundFileNamed("clickSound.wav", waitForCompletion: false)) // TODO: dodaj ścieżkę dźwiękową
            self.pendingUpgrade = upgradeFactory.createUpgrade(option: option)
            
            // Zamykamy popup 1
            self.activePopup = nil
            
            // Teraz otwieramy popup 2 - wybór linii
            self.showLineSelectionPopup()
        }
        
        presentPopup(popup)
    }
    
    func showLineSelectionPopup() {
        let popup = LineSelectionPopup(size: self.size, amountOfLines: routeLines.count) { [weak self] index in
            guard let self = self else { return }
            //self.run(SKAction.playSoundFileNamed("clickSound.wav", waitForCompletion: false)) // TODO: dodaj ścieżkę dźwiękową
            
            if let upgrade = self.pendingUpgrade {
                // Aplikujemy do odpowiedniej linii
                let line = self.routeLines[index]
                upgrade.apply(line: line)
                self.pendingUpgrade = nil
            }
            
            self.activePopup = nil
        }
        
        presentPopup(popup)
    }
}

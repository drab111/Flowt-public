//
//  GameSceneTouchHandling.swift
//  Flowt
//
//  Created by Wiktor Drab on 19/09/2025.
//

import SpriteKit

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Sprawdzamy czy jest widoczne okienko UpgradePopup lub LineSelectionPopup
        if let popup = activePopup as? Popup {
            popup.handleTouch(location)
            return
        }
        
        // Sprawdzamy czy kliknięto w "Menu"
        if nodes(at: location).contains(where: { $0.name == "BackToMenuButton" }) {
            AudioService.shared.playSystemSFX(id: 1110)
            let popup = ConfirmExitPopup(size: self.size,
                onConfirm: { [weak self] in
                    guard let self else { return }
                    AudioService.shared.playSystemSFX(id: 1110)
                    self.invalidateTimers()
                    self.gameVM.backToMenu()
                },
                onCancel: { [weak self] in
                    guard let self else { return }
                    AudioService.shared.playSystemSFX(id: 1110)
                    self.activePopup = nil
                })
            
            addChild(popup)
            activePopup = popup
            return
        }
        
        // Sprawdzamy czy kliknięto w "Pause"
        if nodes(at: location).contains(where: { $0.name == "PauseButton" }) {
            AudioService.shared.playSystemSFX(id: 1110)
            scene?.isPaused.toggle()
            let text = (scene?.isPaused == true) ? "\u{25B6}\u{FE0E}" : "\u{23F8}\u{FE0E}"
            pauseLabel?.text = text
        }
        
        // Sprawdzamy czy kliknięto w przycisk linii i szukamy jej indeksu
        if let tappedButton = nodes(at: location).compactMap({ $0 as? SKShapeNode }).first, let index = colorButtons.firstIndex(of: tappedButton) {
            AudioService.shared.playSFX(node: self, fileName: "clickSound.wav")
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            currentLineIndex = index
            createColorButtons()
            isDrawing = false
            return
        }
        
        if currentLine.isLoop {
            isDrawing = false
            return
        }
        
        if currentLine.permanentPoints.isEmpty {
            isDrawing = true
            currentLine.startNewLine(from: location)
        } else {
            // Sprawdzamy dystans do first i last
            let firstP = currentLine.permanentPoints.first!
            let lastP = currentLine.permanentPoints.last!
            
            let distToFirst = hypot(location.x - firstP.x, location.y - firstP.y)
            let distToLast  = hypot(location.x - lastP.x,  location.y - lastP.y)
            
            // Ustalamy czy bliżej do first czy do last
            if distToFirst < GameConfig.portConnectionTolerance {
                // Rysujemy "od początku"
                isDrawing = true
                // Ale w tym wypadku zapamiętamy że dodajemy na początek
                currentLine.isAppendingAtFront = true
                currentLine.startNewLine(from: firstP)
            } else if distToLast < GameConfig.portConnectionTolerance {
                // normalne rysowanie
                isDrawing = true
                currentLine.isAppendingAtFront = false
                currentLine.startNewLine(from: lastP)
            } else { isDrawing = false }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDrawing, let touch = touches.first else { return }
        let location = touch.location(in: self)
        currentLine.addPoint(location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDrawing, let touch = touches.first else { return }
        
        isDrawing = false
        currentLine.addPoint(touch.location(in: self))
        let pathPoints = currentLine.currentPoints
        
        // Sprawdzenie czy nowa linia spełnia zasady gry aby móc ją zrealizować
        if let (startPort, endPort) = checkConnectionForSegment(points: pathPoints, line: currentLine) {
            AudioService.shared.playSFX(node: self, fileName: "successSound.wav")
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            currentLine.finalizeCurrentLine()
            currentLine.existingConnections.append((startPort, endPort))
            checkIfLoopClosed(line: currentLine)
        } else {
            AudioService.shared.playSFX(node: self, fileName: "failureSound.wav")
            currentLine.currentPoints.removeAll()
            currentLine.updatePath()
        }
    }
}

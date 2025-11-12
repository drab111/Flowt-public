//
//  GameViewUITests.swift
//  Flowt
//
//  Created by Wiktor Drab on 09/11/2025.
//

import XCTest

final class GameViewUITests: XCTestCase {
    private let defaultTimeout: TimeInterval = 60
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["USE_MOCK_SERVICES"] = "1"
        app.launchEnvironment["SKIP_TERMS_AGREEMENT"] = "1"
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helpers
    
    private func signIn() {
        app.launch()
        let emailField = app.textFields["login_emailTextField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: defaultTimeout))
        emailField.tap()
        
        let keyboard = app.keyboards.firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: defaultTimeout))
        emailField.typeText("ui-test@example.com")
        
        let passwordField = app.secureTextFields["login_passwordSecureTextField"]
        tapElementAndWaitForKeyboardToAppear(passwordField, app: app, timeout: defaultTimeout)
        passwordField.typeText("Password123")

        let signInButton = app.buttons["login_submitButton"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: defaultTimeout))
        XCTAssertTrue(signInButton.isEnabled)
        signInButton.tap()

        // wait for tabBar
        let tabBar = app.otherElements["mainMenu_tabBar"]
        XCTAssertTrue(tabBar.waitForExistence(timeout: defaultTimeout))

        // profile view verification
        let profileTextField = app.textFields["profile_nicknameTextField"]
        XCTAssertTrue(profileTextField.waitForExistence(timeout: defaultTimeout))
    }

    private func openGameTab() {
        let gameTab = app.staticTexts["Game"]
        XCTAssertTrue(gameTab.waitForExistence(timeout: defaultTimeout))
        gameTab.tap()
        
        // wait for GameView to be visible
        let playButton = app.buttons["game_playButton"]
        XCTAssertTrue(playButton.waitForExistence(timeout: defaultTimeout))
    }

    // MARK: - UI Tests
    
    func test_enterGame_openMenu_and_returnToGameView() throws {
        signIn()
        openGameTab()

        // start the game (opens SpriteView full screen)
        let playButton = app.buttons["game_playButton"]
        XCTAssertTrue(playButton.isHittable)
        playButton.tap()

        // wait for SpriteKit scene to appear by presence of BackToMenuButton node
        let backToMenuNode = app.otherElements["BackToMenuButton"]
        XCTAssertTrue(backToMenuNode.waitForExistence(timeout: defaultTimeout))
        // tap node to open ConfirmExitPopup
        backToMenuNode.tap()
        
        // first decline the request
        let popupConfirmNoButton = app.otherElements["ConfirmNo"]
        XCTAssertTrue(popupConfirmNoButton.waitForExistence(timeout: defaultTimeout))
        popupConfirmNoButton.tap()
        
        // next tap menu button again
        let reBackToMenuNode = app.otherElements["BackToMenuButton"]
        XCTAssertTrue(reBackToMenuNode.waitForExistence(timeout: defaultTimeout))
        reBackToMenuNode.tap()
        
        // finally quit game
        let popupConfirmYesButton = app.otherElements["ConfirmYes"]
        XCTAssertTrue(popupConfirmYesButton.waitForExistence(timeout: defaultTimeout))
        popupConfirmYesButton.tap()
        
        // after returning to menu the SpriteView is dismissed and GameView is visible again
        let playButtonAfter = app.buttons["game_playButton"]
        XCTAssertTrue(playButtonAfter.waitForExistence(timeout: defaultTimeout))
    }
    
    func test_enterGame_togglePause_changesPauseLabel_and_resumes() throws {
        signIn()
        openGameTab()

        // start game
        let playButton = app.buttons["game_playButton"]
        XCTAssertTrue(playButton.waitForExistence(timeout: defaultTimeout))
        playButton.tap()

        // wait for pause button node (⏸︎)
        let pauseNode = app.otherElements["\u{23F8}\u{FE0E}"]
        XCTAssertTrue(pauseNode.waitForExistence(timeout: defaultTimeout))
        
        // tap pause node to pause the scene
        pauseNode.tap()
        
        // wait for resume button node (▶︎)
        let resumeNode = app.otherElements["\u{25B6}\u{FE0E}"]
        XCTAssertTrue(resumeNode.waitForExistence(timeout: defaultTimeout))

        // tap again to toggle back
        resumeNode.tap()
        
        // wait for pause button node again
        let pauseNodeAfter = app.otherElements["\u{23F8}\u{FE0E}"]
        XCTAssertTrue(pauseNodeAfter.waitForExistence(timeout: defaultTimeout))
    }
    
    func test_debug_endGame_navigatesToEndGame_and_backToGame() throws {
        signIn()
        openGameTab()

        // start game
        let playButton = app.buttons["game_playButton"]
        XCTAssertTrue(playButton.waitForExistence(timeout: defaultTimeout))
        playButton.tap()

        // wait for debug element to appear
        let debugNode = app.otherElements["DebugGameOver"]
        XCTAssertTrue(debugNode.waitForExistence(timeout: defaultTimeout))

        // tap debug to force game over and present EndGameView
        debugNode.tap()

        // EndGameView contains scroll view
        let scrollView = app.scrollViews["endGame_scrollView"]
        XCTAssertTrue(scrollView.waitForExistence(timeout: defaultTimeout))

        // there is a "Back to Menu" button — tap it to go back to GameView
        let backToMenuButton = app.buttons["endGame_backToMenuButton"]
        XCTAssertTrue(backToMenuButton.waitForExistence(timeout: defaultTimeout))
        backToMenuButton.tap()

        // after returning, play button should be visible again
        let playButtonAfter = app.buttons["game_playButton"]
        XCTAssertTrue(playButtonAfter.waitForExistence(timeout: defaultTimeout))
    }
}

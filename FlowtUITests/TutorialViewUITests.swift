//
//  TutorialViewUITests.swift
//  Flowt
//
//  Created by Wiktor Drab on 08/11/2025.
//

import XCTest

final class TutorialViewUITests: XCTestCase {
    private let defaultTimeout: TimeInterval = 20
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

    // MARK: - Helper
    private func signIn() {
        app.launch()
        let emailField = app.textFields["login_emailTextField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: defaultTimeout))
        emailField.tap()
        emailField.typeText("ui-test@example.com")

        let passwordField = app.secureTextFields["login_passwordSecureTextField"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: defaultTimeout))
        passwordField.tap()
        passwordField.typeText("Password123")

        let signInButton = app.buttons["login_submitButton"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: defaultTimeout))
        XCTAssertTrue(signInButton.isEnabled)
        signInButton.tap()

        // wait for profile tabBar or profile view to appear
        let tabBar = app.otherElements["mainMenu_tabBar"]
        XCTAssertTrue(tabBar.waitForExistence(timeout: defaultTimeout))
        
        // profile view has profile_nicknameTextField
        let profileTextField = app.textFields["profile_nicknameTextField"]
        XCTAssertTrue(profileTextField.waitForExistence(timeout: defaultTimeout))
    }
    
    // MARK: - UI Tests
    
    func test_scrollThroughTutorial_and_tapStartPlaying_switchesToGame() throws {
        signIn()
        
        // tap the Tutorial tab in the main menu tab bar
        let tutorialTabLabel = app.staticTexts["Tutorial"]
        XCTAssertTrue(tutorialTabLabel.waitForExistence(timeout: defaultTimeout))
        tutorialTabLabel.tap()
        
        // wait for tutorial scroll view to appear
        let tutorialScroll = app.scrollViews["tutorial_scrollView"]
        XCTAssertTrue(tutorialScroll.waitForExistence(timeout: defaultTimeout))
        
        // try to find the Start Playing button - we will swipe left across the card area
        // repeatedly until the button appears or we hit a max attempts
        let startButton = app.buttons["tutorial_startPlayingButton"]
        var attempts = 0
        let maxAttempts = 12 // safety cap (>= number of tutorial pages)
        while !startButton.exists && attempts < maxAttempts {
            // swipe left inside the scroll view
            tutorialScroll.swipeLeft()
            attempts += 1
            // small sleep to allow animation to settle (waitForExistence will cover longer waits)
            _ = startButton.waitForExistence(timeout: 0.5)
        }
        XCTAssertTrue(startButton.waitForExistence(timeout: defaultTimeout))

        // tap Start Playing
        XCTAssertTrue(startButton.isHittable)
        startButton.tap()
        
        // game start button should appear - we are in game tab
        let gamePlayButton = app.buttons["game_playButton"]
        XCTAssertTrue(gamePlayButton.waitForExistence(timeout: defaultTimeout))
    }
}

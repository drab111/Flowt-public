//
//  LeaderboardViewUITests.swift
//  Flowt
//
//  Created by Wiktor Drab on 09/11/2025.
//

import XCTest

final class LeaderboardViewUITests: XCTestCase {
    private let defaultTimeout: TimeInterval = 20
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["USE_MOCK_SERVICES"] = "1"
        app.launchEnvironment["SKIP_TERMS_AGREEMENT"] = "1"
        app.launchEnvironment["SKIP_LOGIN"] = "1"
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helper
    private func signIn() {
        app.launch()
        
        if app.launchEnvironment["SKIP_LOGIN"] != "1" {
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
        }

        // wait for tabBar
        let tabBar = app.otherElements["mainMenu_tabBar"]
        XCTAssertTrue(tabBar.waitForExistence(timeout: defaultTimeout))

        // profile view verification
        let profileTextField = app.textFields["profile_nicknameTextField"]
        XCTAssertTrue(profileTextField.waitForExistence(timeout: defaultTimeout))
    }
    
    // MARK: - UI Tests

    func test_tapRefresh_leaderboardReloads() throws {
        signIn()
        
        // switch to Leaderboard tab
        let leaderboardLabel = app.staticTexts["Ranks"]
        XCTAssertTrue(leaderboardLabel.waitForExistence(timeout: defaultTimeout))
        leaderboardLabel.tap()
        
        // wait for leaderboard scroll view to appear
        let leaderboardScroll = app.scrollViews["leaderboard_scrollView"]
        XCTAssertTrue(leaderboardScroll.waitForExistence(timeout: defaultTimeout))
        
        // find refresh button and tap it
        let refreshButton = app.buttons["leaderboard_refreshButton"]
        XCTAssertTrue(refreshButton.waitForExistence(timeout: defaultTimeout))
        XCTAssertTrue(refreshButton.isHittable)
        refreshButton.tap()
    }
}

//
//  InfoViewUITests.swift
//  Flowt
//
//  Created by Wiktor Drab on 09/11/2025.
//

import XCTest

final class InfoViewUITests: XCTestCase {
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
    
    // MARK: - Helpers
    
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

        // wait for tabBar
        let tabBar = app.otherElements["mainMenu_tabBar"]
        XCTAssertTrue(tabBar.waitForExistence(timeout: defaultTimeout))

        // profile view verification
        let profileTextField = app.textFields["profile_nicknameTextField"]
        XCTAssertTrue(profileTextField.waitForExistence(timeout: defaultTimeout))
    }
    
    private func openInfoTab() {
        let infoLabel = app.staticTexts["Info"]
        XCTAssertTrue(infoLabel.waitForExistence(timeout: defaultTimeout))
        infoLabel.tap()

        // wait for the scroll view
        let infoScroll = app.scrollViews["info_scrollView"]
        XCTAssertTrue(infoScroll.waitForExistence(timeout: defaultTimeout))
    }
    
    // MARK: - UI Tests
    
    func test_tapping_privacy_opensSheet() throws {
        signIn()
        openInfoTab()
        
        // privacy button
        let privacyButton = app.buttons["info_privacyButton"]
        XCTAssertTrue(privacyButton.waitForExistence(timeout: defaultTimeout))
        privacyButton.tap()
        
        // expect SafariSheet to appear
        let privacyModal = app.otherElements["info_privacyModal"]
        XCTAssertTrue(privacyModal.waitForExistence(timeout: defaultTimeout))
        
        // close the sheet
        let privacyModalButton = privacyModal.buttons.element(boundBy: 0)
        XCTAssertTrue(privacyModalButton.waitForExistence(timeout: defaultTimeout))
        privacyModalButton.tap()
    }
    
    func test_faq_disclosure_expands_and_collapses() throws {
        signIn()
        openInfoTab()

        // find FAQ question
        let questionElement = app.buttons["faq_question_How_is_my_rank_calculated?"]
        XCTAssertTrue(questionElement.waitForExistence(timeout: defaultTimeout))
        questionElement.tap()

        // the answer should appear - identify the answer element
        let answer = app.staticTexts["faq_answer_How_is_my_rank_calculated?"]
        XCTAssertTrue(answer.waitForExistence(timeout: defaultTimeout))

        // tap again to collapse
        XCTAssertTrue(questionElement.exists)
        questionElement.tap()

        // now answer should disappear
        XCTAssertFalse(answer.exists)
    }
    
    func test_techmap_tap_stop_shows_tooltip() throws {
        signIn()
        openInfoTab()
        
        // find tech button
        let techStopButton = app.buttons["techstop_SpriteKit"]
        XCTAssertTrue(techStopButton.waitForExistence(timeout: defaultTimeout))
        techStopButton.tap()

        // tooltip should appear
        let tooltip = app.staticTexts["tech_tooltip_2D_engine"]
        XCTAssertTrue(tooltip.waitForExistence(timeout: defaultTimeout))

        // tap again to hide
        techStopButton.tap()
        XCTAssertFalse(tooltip.exists)
    }
}

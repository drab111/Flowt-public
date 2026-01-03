//
//  TermsAgreementViewUITests.swift
//  Flowt
//
//  Created by Wiktor Drab on 08/11/2025.
//

import XCTest

final class TermsAgreementViewUITests: XCTestCase {
    var app: XCUIApplication!
    private let defaultTimeout: TimeInterval = 20
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["USE_MOCK_SERVICES"] = "1"
        app.launchEnvironment["SKIP_TERMS_AGREEMENT"] = "0"
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - UI Tests
    
    func test_tapping_terms_and_privacy_opensSheets() throws {
        // terms button
        let termsButton = app.buttons["terms_button"]
        XCTAssertTrue(termsButton.waitForExistence(timeout: defaultTimeout))
        termsButton.tap()

        // sheet should appear
        let termsModal = app.otherElements["terms_modal"]
        XCTAssertTrue(termsModal.waitForExistence(timeout: defaultTimeout))
        
        let termsModalButton = termsModal.buttons.element(boundBy: 0)
        XCTAssertTrue(termsModalButton.waitForExistence(timeout: defaultTimeout))
        termsModalButton.tap()

        // privacy button
        let privacyButton = app.buttons["privacy_button"]
        XCTAssertTrue(privacyButton.waitForExistence(timeout: defaultTimeout))
        privacyButton.tap()
        
        let privacyModal = app.otherElements["privacy_modal"]
        XCTAssertTrue(privacyModal.waitForExistence(timeout: defaultTimeout))
        
        let privacyModalButton = privacyModal.buttons.element(boundBy: 0)
        XCTAssertTrue(privacyModalButton.waitForExistence(timeout: defaultTimeout))
        privacyModalButton.tap()
    }
    
    func test_acceptButton_requiresAllToggles_then_proceedsToSignIn() throws {
        // wait for accept button to exist
        let acceptButton = app.buttons["terms_acceptButton"]
        XCTAssertTrue(acceptButton.waitForExistence(timeout: defaultTimeout))

        // initially disabled
        XCTAssertFalse(acceptButton.isEnabled)

        // toggle terms
        let toggleTerms = app.switches["toggle_terms"]
        XCTAssertTrue(toggleTerms.waitForExistence(timeout: defaultTimeout))
        toggleTerms.tap()
        XCTAssertFalse(acceptButton.isEnabled) // still disabled

        // toggle privacy
        let togglePrivacy = app.switches["toggle_privacy"]
        XCTAssertTrue(togglePrivacy.waitForExistence(timeout: defaultTimeout))
        togglePrivacy.tap()
        XCTAssertFalse(acceptButton.isEnabled)

        // toggle age
        let toggleAge = app.switches["toggle_age"]
        XCTAssertTrue(toggleAge.waitForExistence(timeout: defaultTimeout))
        toggleAge.tap()

        // now enabled
        XCTAssertTrue(acceptButton.waitForExistence(timeout: defaultTimeout))
        XCTAssertTrue(acceptButton.isEnabled)
        acceptButton.tap()

        // wait for sign in view element (email field) to appear
        let emailField = app.textFields["login_emailTextField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: defaultTimeout))
    }
}

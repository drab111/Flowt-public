//
//  VerifyEmailViewUITests.swift
//  Flowt
//
//  Created by Wiktor Drab on 09/11/2025.
//

import XCTest

final class VerifyEmailViewUITests: XCTestCase {
    private let defaultTimeout: TimeInterval = 20
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["USE_MOCK_SERVICES"] = "1"
        app.launchEnvironment["SKIP_TERMS_AGREEMENT"] = "1"
        app.launchEnvironment["SET_VERIFY_EMAIL"] = "1"
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
    }
    
    private func ensureVerifyEmailVisible() {
        let header = app.staticTexts["Verify your email"]
        XCTAssertTrue(header.waitForExistence(timeout: defaultTimeout))
    }
    
    // MARK: - UI Tests
    
    func test_resend_showsInfoMessage() throws {
        signIn()
        ensureVerifyEmailVisible()

        // tap resend button
        let resendButton = app.buttons["verify_resendButton"]
        XCTAssertTrue(resendButton.waitForExistence(timeout: defaultTimeout))
        XCTAssertTrue(resendButton.isHittable)
        resendButton.tap()

        // after tapping, VerifyEmailViewModel sets infoMessage
        let infoMessage = app.staticTexts["verify_infoMessage"]
        XCTAssertTrue(infoMessage.waitForExistence(timeout: defaultTimeout))
    }
    
    func test_troubleshooting_disclosure_expands_and_collapses() throws {
        signIn()
        ensureVerifyEmailVisible()

        // tap disclosure button
        let question = app.buttons["verify_tips_question"]
        XCTAssertTrue(question.waitForExistence(timeout: defaultTimeout))
        question.tap()
        
        // the answer should appear
        let answer = app.staticTexts["verify_tips_answer"]
        XCTAssertTrue(answer.waitForExistence(timeout: defaultTimeout))
        question.tap()
        
        // now answer should disappear
        XCTAssertFalse(answer.exists)
    }
    
    func test_signOut_returnsToSignInView() throws {
        signIn()
        ensureVerifyEmailVisible()
        
        // tap sign out button
        let signOutButton = app.buttons["verify_signOutButton"]
        XCTAssertTrue(signOutButton.waitForExistence(timeout: defaultTimeout))
        XCTAssertTrue(signOutButton.isHittable)
        signOutButton.tap()
        
        // after sign out, we expect to be at SignIn view (email field present)
        let emailField = app.textFields["login_emailTextField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: defaultTimeout))
    }
}

//
//  SignInViewUITests.swift
//  Flowt
//
//  Created by Wiktor Drab on 07/11/2025.
//

import XCTest

final class SignInViewUITests: XCTestCase {
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
    
    // MARK: - UI Tests

    func test_signIn_success_showsMainMenu() throws {
        app.launch()
        
        // wait for the email field
        let emailField = app.textFields["login_emailTextField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: defaultTimeout))

        // enter email and password
        emailField.tap()
        let keyboard = app.keyboards.firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: defaultTimeout))
        emailField.typeText("ui-test@example.com")

        let passwordField = app.secureTextFields["login_passwordSecureTextField"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: defaultTimeout))
        passwordField.tap()
        sleep(3)
        let passwordKeyboard = app.keyboards.firstMatch
        XCTAssertTrue(passwordKeyboard.waitForExistence(timeout: defaultTimeout))
        passwordField.typeText("Password123")

        // tap the Sign In button
        let signInButton = app.buttons["login_submitButton"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: defaultTimeout))
        XCTAssertTrue(signInButton.isEnabled)

        signInButton.tap()

        // wait for the main menu to appear
        let tabBar = app.otherElements["mainMenu_tabBar"]
        XCTAssertTrue(tabBar.waitForExistence(timeout: defaultTimeout))
    }
    
    func test_signIn_buttonDisabledForInvalidForm() throws {
        app.launch()
        
        // enter invalid email
        let emailField = app.textFields["login_emailTextField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: defaultTimeout))
        emailField.tap()
        
        let keyboard = app.keyboards.firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: defaultTimeout))
        emailField.typeText("ui-test@example.com")

        // enter too short password
        let passwordField = app.secureTextFields["login_passwordSecureTextField"]
        passwordField.tap()
        sleep(3)
        let passwordKeyboard = app.keyboards.firstMatch
        XCTAssertTrue(passwordKeyboard.waitForExistence(timeout: defaultTimeout))
        passwordField.typeText("short") // < 8

        // check that Sign In button is disabled
        let signInButton = app.buttons["login_submitButton"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: defaultTimeout))
        XCTAssertFalse(signInButton.isEnabled)
    }
    
    func test_signIn_showsErrorOnAuthFailure() throws {
        app.launchEnvironment["MOCK_AUTH_SHOULD_THROW_SIGNIN"] = "1"
        app.launch()
        
        // wait for the email field
        let emailField = app.textFields["login_emailTextField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: defaultTimeout))

        // enter email and password
        emailField.tap()
        let keyboard = app.keyboards.firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: defaultTimeout))
        emailField.typeText("ui-test@example.com")

        let passwordField = app.secureTextFields["login_passwordSecureTextField"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: defaultTimeout))
        passwordField.tap()
        sleep(3)
        let passwordKeyboard = app.keyboards.firstMatch
        XCTAssertTrue(passwordKeyboard.waitForExistence(timeout: defaultTimeout))
        passwordField.typeText("Password123")

        // tap the Sign In button
        let signInButton = app.buttons["login_submitButton"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: defaultTimeout))
        signInButton.tap()

        // expect error banner
        let errorBanner = app.otherElements["login_errorBanner"]
        XCTAssertTrue(errorBanner.waitForExistence(timeout: defaultTimeout))
    }
    
    func test_forgotPassword_sendsLink_showsInfo() throws {
        app.launch()

        let forgotButton = app.buttons["forgot_password_button"]
        XCTAssertTrue(forgotButton.waitForExistence(timeout: defaultTimeout))
        forgotButton.tap()

        let sheetEmail = app.textFields["forgot_sheet_email"]
        XCTAssertTrue(sheetEmail.waitForExistence(timeout: defaultTimeout))
        sheetEmail.tap()
        let keyboard = app.keyboards.firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: defaultTimeout))
        sheetEmail.typeText("ui-test@example.com")
        
        let sendButton = app.buttons["forgot_send_link_button"]
        XCTAssertTrue(sendButton.waitForExistence(timeout: defaultTimeout))
        sendButton.tap()

        // after success authVM.infoMessage should be set - info banner shown
        let infoBanner = app.otherElements["login_infoBanner"]
        XCTAssertTrue(infoBanner.waitForExistence(timeout: defaultTimeout))
    }
    
    func test_toggleMode_changesSubmitButtonLabel() throws {
        app.launch()

        let modeSwitch = app.buttons["auth_mode_switch_button"]
        XCTAssertTrue(modeSwitch.waitForExistence(timeout: defaultTimeout))

        let submitButton = app.buttons["login_submitButton"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: defaultTimeout))
        // initial should be "Sign In"
        XCTAssertEqual(submitButton.label, "Sign In")

        modeSwitch.tap()
        // small wait for animation / state
        XCTAssertTrue(submitButton.waitForExistence(timeout: defaultTimeout))
        XCTAssertEqual(submitButton.label, "Sign Up")

        // tap again - back to Sign In
        modeSwitch.tap()
        XCTAssertTrue(submitButton.waitForExistence(timeout: defaultTimeout))
        XCTAssertEqual(submitButton.label, "Sign In")
    }
}

//
//  ProfileViewUITests.swift
//  Flowt
//
//  Created by Wiktor Drab on 08/11/2025.
//

import XCTest

final class ProfileViewUITests: XCTestCase {
    private let defaultTimeout: TimeInterval = 60
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

        // wait for profile tabBar or profile view to appear
        let tabBar = app.otherElements["mainMenu_tabBar"]
        XCTAssertTrue(tabBar.waitForExistence(timeout: defaultTimeout))
        
        // profile view has profile_nicknameTextField
        let profileTextField = app.textFields["profile_nicknameTextField"]
        XCTAssertTrue(profileTextField.waitForExistence(timeout: defaultTimeout))
    }
    
    func test_nickname_truncation_limitsTo15Chars() throws {
        signIn()
        
        // put long nickname into field
        let nicknameField = app.textFields["profile_nicknameTextField"]
        XCTAssertTrue(nicknameField.exists)
        nicknameField.tap()
        let keyboard = app.keyboards.firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: defaultTimeout))
        
        // clear existing text (if any) - send selectAll + delete for robust clearing
        nicknameField.press(forDuration: 1.0)
        if app.menuItems["Select All"].exists { app.menuItems["Select All"].tap() }
        nicknameField.typeText(String(repeating: "x", count: 30)) // 30 chars
        
        // check that field text was trimmed to <= 15 (the View enforces in onChange)
        let value = nicknameField.value as? String ?? ""
        XCTAssertTrue(value.count <= 15)
    }

    func test_submitButton_saveFlow_and_states() throws {
        signIn()
        
        // set a new short nickname
        let nicknameField = app.textFields["profile_nicknameTextField"]
        XCTAssertTrue(nicknameField.exists)
        nicknameField.tap()
        let keyboard = app.keyboards.firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: defaultTimeout))

        // clear + enter new nickname
        nicknameField.press(forDuration: 0.5)
        if app.menuItems["Select All"].exists { app.menuItems["Select All"].tap() }
        nicknameField.typeText("NewNick")

        // find button and save
        let saveButton = app.buttons["profile_saveButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: defaultTimeout))
        XCTAssertTrue(saveButton.isHittable)
        saveButton.tap()

        // after save occurs, ProfileViewModel sets saveState = .saving -> .saved -> .idle; UI shows "Saved!" label on .saved
        let savedLabel = app.staticTexts["profile_savedLabel"]
        XCTAssertTrue(savedLabel.waitForExistence(timeout: defaultTimeout))

        // check that new nickname propagated to header
        let headerNickname = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "NewNick")).firstMatch
        XCTAssertTrue(headerNickname.waitForExistence(timeout: defaultTimeout))
    }
    
    func test_updateProfile_withInappropriateAvatar_showsRejectedState() throws {
        app.launchEnvironment["MOCK_PROFILE_SHOULD_RETURN_FALSE_ON_VALIDATE"] = "1"
        app.launchEnvironment["PRELOAD_AVATAR_BASE64"] = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII="
        signIn()

        let saveButton = app.buttons["profile_saveButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: defaultTimeout))
        saveButton.tap()

        let rejectedLabel = app.staticTexts["profile_rejectedLabel"]
        XCTAssertTrue(rejectedLabel.waitForExistence(timeout: defaultTimeout))
    }

    
    func test_signOut_showsAlert_and_confirms() throws {
        signIn()
        
        let signOutButton = app.buttons["profile_signOutButton"]
        XCTAssertTrue(signOutButton.waitForExistence(timeout: defaultTimeout))
        signOutButton.tap()
        
        let alert = app.alerts["Confirm Sign Out"]
        XCTAssertTrue(alert.waitForExistence(timeout: defaultTimeout))
        
        // tap destructive "Sign Out" button inside alert
        let signOutButtonInAlert = alert.buttons["Sign Out"]
        XCTAssertTrue(signOutButtonInAlert.exists)
        signOutButtonInAlert.tap()
        
        // after sign out we expect to be at SignIn view (email field present)
        let emailField = app.textFields["login_emailTextField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: defaultTimeout))
    }
    
    func test_deleteAccount_showsAlert_and_handlesServiceError() throws {
        app.launchEnvironment["MOCK_AUTH_SHOULD_THROW_DELETE"] = "1"
        app.launchEnvironment["MOCK_PROFILE_SHOULD_THROW_DELETE"] = "1"
        app.launchEnvironment["MOCK_SCORE_SHOULD_THROW_DELETE"] = "1"
        signIn()

        let deleteButton = app.buttons["profile_deleteButton"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: defaultTimeout))
        deleteButton.tap()

        // alert appears with "Delete Account"
        let alert = app.alerts["Delete Account"]
        XCTAssertTrue(alert.waitForExistence(timeout: defaultTimeout))
        
        let deleteButtonInAlert = alert.buttons["Delete Account"]
        XCTAssertTrue(deleteButtonInAlert.exists)
        deleteButtonInAlert.tap()

        // since mock throws, we should remain on profile
        let profileButton = app.buttons["profile_saveButton"]
        XCTAssertTrue(profileButton.waitForExistence(timeout: defaultTimeout))
        
        // error message should appear
        let errorMessage = app.staticTexts["profile_errorMessage"]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: defaultTimeout))
    }
    
    func test_deleteAccount_showsAlert_and_confirmsDeletion() throws {
        signIn()
        
        let deleteButton = app.buttons["profile_deleteButton"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: defaultTimeout))
        deleteButton.tap()

        // alert appears with "Delete Account"
        let alert = app.alerts["Delete Account"]
        XCTAssertTrue(alert.waitForExistence(timeout: defaultTimeout))
        
        let deleteButtonInAlert = alert.buttons["Delete Account"]
        XCTAssertTrue(deleteButtonInAlert.exists)
        deleteButtonInAlert.tap()
        
        // after delete account we expect to be at SignIn view
        let emailField = app.textFields["login_emailTextField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: defaultTimeout))
    }
}

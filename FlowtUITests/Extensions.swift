//
//  Extensions.swift
//  Flowt
//
//  Created by Wiktor Drab on 11/11/2025.
//

import XCTest

extension XCTestCase {
    // tap the element and wait for the software keyboard to appear
    // uses the provided 'app' instance, retries taps a few times and uses XCT expectations with timeout.
    func tapElementAndWaitForKeyboardToAppear(_ element: XCUIElement, app: XCUIApplication, timeout: TimeInterval = 5.0, maxAttempts: Int = 3) {
        // element must exist first
        XCTAssertTrue(element.waitForExistence(timeout: timeout))
        
        let keyboard = app.keyboards.firstMatch
        var attempt = 0
        while attempt < maxAttempts {
            attempt += 1
            element.tap()
            
            // wait for keyboard to exist
            let exp = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: keyboard)
            let result = XCTWaiter().wait(for: [exp], timeout: 1.0) // short per-attempt wait
            if result == .completed { return } // success

            // small backoff before next attempt
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.2))
        }

        // final wait with provided timeout
        let finalExp = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: keyboard)
        let finalResult = XCTWaiter().wait(for: [finalExp], timeout: timeout)
        XCTAssertEqual(finalResult, .completed)
    }
}

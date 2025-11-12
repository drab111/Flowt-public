//
//  InfoViewModelTests.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/10/2025.
//

import XCTest
@testable import Flowt

@MainActor
final class InfoViewModelTests: XCTestCase {
    // MARK: - tests
    func test_URLs_are_not_empty() {
        // Arrange
        let vm = InfoViewModel()
        
        // Assert
        XCTAssertFalse(vm.termsURL.absoluteString.isEmpty)
        XCTAssertFalse(vm.privacyURL.absoluteString.isEmpty)
    }
}

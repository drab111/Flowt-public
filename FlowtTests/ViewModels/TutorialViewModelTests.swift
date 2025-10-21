//
//  TutorialViewModelTests.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/10/2025.
//

import XCTest
@testable import Flowt

@MainActor
final class TutorialViewModelTests: XCTestCase {
    // MARK: - tests
    func test_initialState_hasFirstPageAndCorrectCount() {
        // Arrange
        let vm = TutorialViewModel()
        
        // Assert
        XCTAssertEqual(vm.currentIndex, 0)
        XCTAssertEqual(vm.pages.count, 12)
    }

    func test_nextPage_incrementsUntilLast() {
        // Arrange
        let vm = TutorialViewModel()
        let lastIndex = vm.pages.count - 1
        
        // Act & Assert
        for i in 0..<lastIndex {
            XCTAssertEqual(vm.currentIndex, i)
            vm.nextPage()
        }

        // further nextPage should not change index (stay at last)
        vm.nextPage()
        XCTAssertEqual(vm.currentIndex, lastIndex)
    }

    func test_prevPage_decrementsUntilZero() {
        // Arrange
        let vm = TutorialViewModel()
        vm.currentIndex = vm.pages.count - 1
        
        // Act & Assert
        for i in stride(from: vm.pages.count - 1, to: 0, by: -1) {
            XCTAssertEqual(vm.currentIndex, i)
            vm.prevPage()
        }

        // attempt to go below 0
        vm.prevPage()
        XCTAssertEqual(vm.currentIndex, 0)
    }
}

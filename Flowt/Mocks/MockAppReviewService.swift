#if DEBUG

//
//  MockAppReviewService.swift
//  Flowt
//
//  Created by Wiktor Drab on 13/12/2025.
//

@MainActor
final class MockAppReviewService: AppReviewServiceProtocol {
    private(set) var requestCount: Int = 0
    private(set) var didRequestReview: Bool = false
    var shouldIgnoreRequest: Bool = false
    
    func requestAppReview() {
        guard !shouldIgnoreRequest else { return }
        requestCount += 1
        didRequestReview = true
    }
}

#endif

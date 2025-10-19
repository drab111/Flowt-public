//
//  InfoViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 30/09/2025.
//

import SwiftUI

@MainActor
final class InfoViewModel: ObservableObject {
    // MARK: - URLs
    let termsURL = URL(string: "https://flowt-support.notion.site/Flowt-27e268ff3eaa8019bc63deeb543e4f91")!
    let privacyURL = URL(string: "https://flowt-support.notion.site/Flowt-27e268ff3eaa80ccbdffe9b63c1041ca")!
}

//
//  InfoViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 30/09/2025.
//

import SwiftUI

@MainActor
final class InfoViewModel: ObservableObject {
    let termsURL = URL(string: "https://respected-tuck-d26.notion.site/Flowt-27e268ff3eaa8019bc63deeb543e4f91?source")!
    let privacyURL = URL(string: "https://respected-tuck-d26.notion.site/Flowt-27e268ff3eaa80ccbdffe9b63c1041ca?source")!
    
    func contactSupport() {
        guard let url = URL(string: "mailto:flowt.apps@gmail.com") else { return }
        UIApplication.shared.open(url)
    }
}

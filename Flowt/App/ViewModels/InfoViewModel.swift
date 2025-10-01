//
//  InfoViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 30/09/2025.
//

import SwiftUI

@MainActor
final class InfoViewModel: ObservableObject {
    
    func openPrivacyPolicy() {
        openURL("https://respected-tuck-d26.notion.site/Flowt-27e268ff3eaa80ccbdffe9b63c1041ca?source")
    }
    
    func openTermsOfService() {
        openURL("https://respected-tuck-d26.notion.site/Flowt-27e268ff3eaa8019bc63deeb543e4f91?source")
    }
    
    func contactSupport() {
        openURL("mailto:flowt.apps@gmail.com")
    }
    
    func rateApp() {
        openURL("itms-apps://itunes.apple.com/app/idYOUR_APP_ID?action=write-review")
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

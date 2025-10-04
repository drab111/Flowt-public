//
//  SafariSheet.swift
//  Flowt
//
//  Created by Wiktor Drab on 04/10/2025.
//

import SafariServices
import SwiftUI

// Wewnątrz naszej aplikacji otwiera się strona
struct SafariSheet: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.preferredBarTintColor = UIColor(Color.black.opacity(0.9))
        vc.preferredControlTintColor = UIColor.white
        return vc
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

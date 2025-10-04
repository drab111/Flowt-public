//
//  AvatarCircle.swift
//  Flowt
//
//  Created by Wiktor Drab on 03/10/2025.
//

import SwiftUI

// Awatar z UserProfile.avatarBase64 (gdy nie ma to ustawiamy FlowtLogo)
struct AvatarCircle: View {
    let base64: String?
    let fallback: String
    let size: CGFloat
    var body: some View {
        Group {
            if let base64, let data = Data(base64Encoded: base64), let ui = UIImage(data: data) {
                Image(uiImage: ui).resizable()
            } else {
                Image(fallback).resizable()
            }
        }
        .scaledToFill()
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

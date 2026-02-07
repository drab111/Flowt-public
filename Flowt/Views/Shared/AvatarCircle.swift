//
//  AvatarCircle.swift
//  Flowt
//
//  Created by Wiktor Drab on 03/10/2025.
//

import SwiftUI

// Avatar from UserProfile.avatarBase64 (fallback to FlowtLogo if missing)
struct AvatarCircle: View {
    @State private var uiImage: UIImage?
    let base64: String?
    let fallback: String
    let size: CGFloat

    // MARK: - Body
    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                Image(fallback)
                    .resizable()
            }
        }
        .scaledToFill()
        .frame(width: size, height: size)
        .clipShape(Circle())
        .task(id: base64) { await decodeAndSetImage(base64: base64) }
    }
    
    // MARK: - Helpers
    func decodeAndSetImage(base64: String?) async {
        guard let string = base64?.trimmingCharacters(in: .whitespacesAndNewlines), !string.isEmpty, let data = Data(base64Encoded: string), let image = UIImage(data: data)
        else {
            uiImage = nil
            return
        }

        uiImage = image
    }
}

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
        // Fallback when no data is available
        guard let string = base64?.trimmingCharacters(in: .whitespacesAndNewlines), !string.isEmpty else {
            await MainActor.run { uiImage = nil }
            return
        }

        // Decode in the background without blocking the UI
        let decoded: UIImage? = await Task.detached(priority: .utility) {
            guard let data = Data(base64Encoded: string) else { return nil }
            return UIImage(data: data)
        }.value // Wait asynchronously (await) until the task completes and return its result
        // (since Task.detached doesn’t normally wait for a result)

        // If decoding fails — keep the fallback
        await MainActor.run { uiImage = decoded }
    }
}

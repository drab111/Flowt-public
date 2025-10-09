//
//  AvatarCircle.swift
//  Flowt
//
//  Created by Wiktor Drab on 03/10/2025.
//

import SwiftUI

// Awatar z UserProfile.avatarBase64 (gdy nie ma to ustawiamy fallback - FlowtLogo)
struct AvatarCircle: View {
    @State private var uiImage: UIImage?
    let base64: String?
    let fallback: String
    let size: CGFloat

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
}

// MARK: - Helpers
private extension AvatarCircle {
    func decodeAndSetImage(base64: String?) async {
        // gdy nic nie ma - fallback
        guard let string = base64?.trimmingCharacters(in: .whitespacesAndNewlines), !string.isEmpty else {
            await MainActor.run { uiImage = nil }
            return
        }

        // dekodujemy w tle i nie blokujemy UI
        let decoded: UIImage? = await Task.detached(priority: .utility) {
            guard let data = Data(base64Encoded: string) else { return nil }
            return UIImage(data: data)
        }.value // czeka asynchronicznie (await) aż zadanie się zakończy i zwraca jego wynik (bo w Task.detached nie czekamy normalnie na wynik)

        // jeżeli dekodowanie się nie udało — zostaje fallback
        await MainActor.run { uiImage = decoded }
    }
}

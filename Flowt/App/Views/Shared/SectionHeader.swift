//
//  SectionHeader.swift
//  Flowt
//
//  Created by Wiktor Drab on 03/10/2025.
//

import SwiftUI

struct SectionHeader: View {
    var title: String
    var subtitle: String? = nil
    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 4)
                .fill(.cyan)
                .frame(width: 4, height: 18)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.9))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6)) }
            }
            Spacer()
        }
    }
}

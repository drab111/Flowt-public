//
//  GlassField.swift
//  Flowt
//
//  Created by Wiktor Drab on 04/10/2025.
//

import SwiftUI

struct GlassField<Value: Hashable>: View {
    let systemIcon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var submitLabel: SubmitLabel = .done
    var focused: FocusState<Value?>.Binding
    var field: Value
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemIcon)
                .foregroundStyle(.white.opacity(0.75))

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .submitLabel(submitLabel)
                        .onSubmit { onSubmit?() }
                        .focused(focused, equals: field)
                } else {
                    TextField(placeholder, text: $text)
                        .submitLabel(submitLabel)
                        .onSubmit { onSubmit?() }
                        .focused(focused, equals: field)
                }
            }
            .padding(.vertical, 10)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(focused.wrappedValue == field ? Color.cyan : Color.white.opacity(0.08), lineWidth: 1.5)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture { focused.wrappedValue = field }
    }
}

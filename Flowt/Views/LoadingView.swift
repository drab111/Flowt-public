//
//  LoadingView.swift
//  Flowt
//
//  Created by Wiktor Drab on 26/08/2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        Image("FlowtLogo")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView()
}

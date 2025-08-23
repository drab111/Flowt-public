//
//  MainMenuView.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/08/2025.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject var viewModel: MainMenuViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Main Menu")
                .font(.largeTitle)
                .bold()
            
            Button {
                viewModel.goToAccount()
            } label: {
                Label("My Account", systemImage: "person.circle")
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
            
            Button(role: .destructive) {
                viewModel.signOut()
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
        .padding()
    }
}



#Preview {
    let appState = AppState()
    let viewModel = MainMenuViewModel(appState: appState)
    MainMenuView(viewModel: viewModel)
        .environmentObject(appState)
}

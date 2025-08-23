//
//  AccountView.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/08/2025.
//

import SwiftUI
import PhotosUI

struct AccountView: View {
    @StateObject var viewModel: UserProfileViewModel
    @State private var pickerItem: PhotosPickerItem? = nil // wybrany element z selektora zdjęć
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading {
                ProgressView()
                    .frame(width: 120, height: 120)
            } else if let data = viewModel.avatarData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .clipped()
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay(Text("Avatar"))
            }
            
            PhotosPicker("Select Avatar", selection: $pickerItem, matching: .images)
                .onChange(of: pickerItem) { _, newItem in // newItem to obiekt typu PhotosPickerItem
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) { // surowe dane binarne
                            viewModel.avatarData = data
                        }
                    }
                }
            
            Label("Nickname: \(viewModel.currentNickname)", systemImage: "person.crop.circle")
                .font(.headline)
                .padding()
            
            TextField("Change nickname", text: $viewModel.currentNickname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save Profile") {
                Task { await viewModel.updateProfile(nickname: viewModel.currentNickname, imageData: viewModel.avatarData) }
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        .task { await viewModel.loadUserProfile() }
    }
}


#Preview {
    let appState = AppState()
    let viewModel = UserProfileViewModel(appState: appState)
    AccountView(viewModel: viewModel)
        .environmentObject(appState)
}

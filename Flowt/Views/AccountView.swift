//
//  AccountView.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/08/2025.
//

import SwiftUI
import PhotosUI

struct AccountView: View {
    @StateObject var authVM: AuthViewModel
    @StateObject var userProfileVM: UserProfileViewModel
    @State private var pickerItem: PhotosPickerItem? = nil // wybrany element z selektora zdjęć
    
    var body: some View {
        VStack(spacing: 20) {
            if userProfileVM.isLoading {
                ProgressView()
                    .frame(width: 120, height: 120)
            } else if let data = userProfileVM.avatarData, let image = UIImage(data: data) {
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
                            userProfileVM.avatarData = data
                        }
                    }
                }
            
            Label("Nickname: \(userProfileVM.currentNickname)", systemImage: "person.crop.circle")
                .font(.headline)
                .padding()
            
            TextField("Change nickname", text: $userProfileVM.currentNickname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save Profile") {
                Task { await userProfileVM.updateProfile(nickname: userProfileVM.currentNickname, imageData: userProfileVM.avatarData) }
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
            
            Button(role: .destructive) {
                authVM.signOut()
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
            
            Button(role: .destructive) {
                Task {
                    await userProfileVM.deleteProfile()
                    await authVM.deleteUserAccount()
                }
            } label: {
                Text("Delete Account")
            }
            .padding()
        }
        .padding()
        .task { await userProfileVM.loadUserProfile() }
    }
}


#Preview {
    let appState = AppState()
    let userProfileVM = UserProfileViewModel(appState: appState)
    let authVM = AuthViewModel(appState: appState)
    
    AccountView(authVM: authVM, userProfileVM: userProfileVM)
        .environmentObject(appState)
}

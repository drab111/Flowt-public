//
//  ProfileView.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/08/2025.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    enum ActiveAlert: Identifiable {
        case signOut, deleteAccount
        
        var id: Int {
            switch self {
            case .signOut: return 1
            case .deleteAccount: return 2
            }
        }
    }
    
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var userProfileVM: ProfileViewModel
    @ObservedObject var accountScoreVM: AccountScoreViewModel
    @State private var pickerItem: PhotosPickerItem? = nil // wybrany element w selektorze zdjęć
    @State private var activeAlert: ActiveAlert? = nil
    @FocusState private var focusedField: Bool
    
    var body: some View {
        ZStack {
            if userProfileVM.isLoading || accountScoreVM.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        Group {
                            // MARK: - Profil użytkownika
                            profilePanel
                            
                            // MARK: - Pozycja w rankingu
                            scorePanel
                            
                            // MARK: - Preferencje użytkownika
                            preferencesPanel
                            
                            // MARK: - Akcje konta
                            actionsPanel
                        }
                        .padding()
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.15), lineWidth: 1))
                    }
                    .padding()
                }
            }
        }
        .task {
            await userProfileVM.loadUserProfile()
            await accountScoreVM.loadUserStats()
        }
        .onTapGesture { focusedField = false }
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .signOut:
                return Alert(
                    title: Text("Confirm Sign Out"),
                    message: Text("You are about to sign out of your account. You can sign back in at any time."),
                    primaryButton: .destructive(Text("Sign Out")) { authVM.signOut() },
                    secondaryButton: .cancel(Text("Stay Logged In"))
                )
            case .deleteAccount:
                return Alert(
                    title: Text("Delete Account"),
                    message: Text("This will permanently remove your account and all associated data. This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete Account")) {
                        Task {
                            await userProfileVM.deleteProfile()
                            await authVM.deleteUserAccount()
                            await accountScoreVM.deleteUserScores()
                        }
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
        }

    }
    
    // MARK: - Panel profilu
    private var profilePanel: some View {
        VStack(spacing: 16) {
            Group {
                if let data = userProfileVM.avatarData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                } else {
                    Image("FlowtLogo")
                        .resizable()
                }
            }
            .scaledToFill()
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 2))
            .frame(width: 140, height: 140)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            Text(userProfileVM.currentNickname)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            PhotosPicker("Change Avatar", selection: $pickerItem, matching: .images)
                .onChange(of: pickerItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            userProfileVM.avatarData = data
                        }
                    }
                }
                .buttonStyle(.bordered)
                .tint(.blue.opacity(0.65))
            
            TextField("Enter new nickname", text: $userProfileVM.newNickname)
                .focused($focusedField)
                .padding(10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .foregroundColor(.white)
                .onChange(of: userProfileVM.newNickname) { _, newValue in
                    if newValue.count > 15 { userProfileVM.newNickname = String(newValue.prefix(15)) }
                }
            
            switch userProfileVM.saveState {
            case .idle:
                Button {
                    Task { await userProfileVM.updateProfile(nickname: userProfileVM.newNickname, imageData: userProfileVM.avatarData) }
                    focusedField = false
                } label: {
                    Text("Save Changes")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
                .gradientBackground()
                .foregroundColor(.white)
                .cornerRadius(20)

            case .saving:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .gradientBackground()
                    .cornerRadius(20)

            case .saved:
                Label("Saved!", systemImage: "checkmark.circle.fill")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                
            case .rejected:
                Label("Inappropriate avatar!", systemImage: "xmark.octagon.fill")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
    }
    
    // MARK: - Panel wyniku
    private var scorePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            if let error = accountScoreVM.errorMessage {
                Text(error)
                    .foregroundColor(.yellow)
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Highest Score")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(accountScoreVM.bestScore ?? 0)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Rank")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                        if let rank = accountScoreVM.globalRank {
                            Text("#\(rank)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        } else {
                            Text("-")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Panel preferencji
    private var preferencesPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferences")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            Toggle(isOn: Binding(
                get: { userProfileVM.appState.currentUserProfile?.musicEnabled ?? true },
                set: { newValue in
                    if var profile = userProfileVM.appState.currentUserProfile {
                        profile.musicEnabled = newValue
                        userProfileVM.appState.currentUserProfile = profile
                    }
                    Task {
                        await userProfileVM.updatePreferences(
                            musicEnabled: newValue,
                            sfxEnabled: userProfileVM.appState.currentUserProfile?.sfxEnabled ?? true
                        )
                    }
                }
            )) { Label("Music", systemImage: "music.note") }
            .tint(.blue)

            
            Toggle(isOn: Binding(
                get: { userProfileVM.appState.currentUserProfile?.sfxEnabled ?? true },
                set: { newValue in
                    if var profile = userProfileVM.appState.currentUserProfile {
                        profile.sfxEnabled = newValue
                        userProfileVM.appState.currentUserProfile = profile
                    }
                    Task {
                        await userProfileVM.updatePreferences(
                            musicEnabled: userProfileVM.appState.currentUserProfile?.musicEnabled ?? true,
                            sfxEnabled: newValue
                        )
                    }
                }
            )) { Label("Sound Effects", systemImage: "speaker.wave.2.fill") }
            .tint(.blue)
        }
    }

    
    // MARK: - Panel akcji
    private var actionsPanel: some View {
        VStack(spacing: 12) {
            Button {
                activeAlert = .signOut
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .gradientBackground()
            .foregroundColor(.white)
            .cornerRadius(20)
            
            Button {
                activeAlert = .deleteAccount
            } label: {
                Label("Delete Account", systemImage: "trash")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.red).opacity(0.75)
            .foregroundColor(.white)
            .cornerRadius(20)
        }
    }
}


#Preview {
    let appState = AppState()
    let userProfileVM = ProfileViewModel(appState: appState, profileService: ProfileService())
    let authVM = AuthViewModel(appState: appState, authService: AuthService())
    let accountScoreVM = AccountScoreViewModel(appState: appState, scoreService: ScoreService())
    
    ProfileView(authVM: authVM, userProfileVM: userProfileVM, accountScoreVM: accountScoreVM)
        .environmentObject(appState)
}

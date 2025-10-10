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
    @State private var signOutButtonPressed = false
    @State private var deleteButtonPressed = false
    @FocusState private var focusedField: Int?
    
    var body: some View {
        ZStack {
            if userProfileVM.isLoading || accountScoreVM.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        profilePanel
                        scorePanel
                        preferencesPanel
                        actionsPanel
                    }
                    .padding()
                }
            }
        }
        .task {
            await userProfileVM.loadUserProfile()
            await accountScoreVM.loadUserStats()
        }
        .onTapGesture { focusedField = nil }
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
                            await accountScoreVM.deleteUserScores()
                            await userProfileVM.deleteProfile()
                            await authVM.deleteUserAccount()
                        }
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
        }
    }
    
    // MARK: - Panels
    
    private var profilePanel: some View {
        EdgeLitContainer {
            VStack(spacing: 20) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color.cyan.opacity(0.4), Color.teal.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 150, height: 150)
                        .shadow(color: Color.cyan.opacity(0.5), radius: 20, x: 5, y: 5)
                        .blur(radius: 1)
                        .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 4).frame(width: 150, height: 150))
                    
                    Group {
                        if let data = userProfileVM.avatarData, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .accessibilityLabel("Avatar of \(userProfileVM.currentNickname)")
                        } else {
                            Image("FlowtLogo")
                                .resizable()
                        }
                    }
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                }
                .overlay(alignment: .bottomTrailing) {
                    if userProfileVM.avatarData == nil {
                        PhotosPicker(selection: $pickerItem, matching: .images) {
                            Circle()
                                .fill(LinearGradient(colors: [Color.cyan.opacity(0.6), Color.teal.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                )
                                .shadow(color: Color.cyan.opacity(0.6), radius: 6, x: 0, y: 2)
                                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                        .onChange(of: pickerItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    withAnimation { userProfileVM.avatarData = data }
                                }
                            }
                        }
                        .accessibilityLabel("Change avatar")
                        .accessibilityHint("Opens photo picker.")
                    } else {
                        Button { withAnimation {
                            userProfileVM.avatarData = nil
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        } } label: {
                            Circle()
                                .fill(Color.red.opacity(0.6))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                )
                                .shadow(color: Color.red.opacity(0.6), radius: 6, x: 0, y: 2)
                                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                        .accessibilityLabel("Remove avatar")
                    }
                }
                
                // Nickname
                Text(userProfileVM.currentNickname)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(LinearGradient(colors: [.white, .cyan.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 3)
                
                // Text Field
                GlassField(systemIcon: "pencil.and.outline", placeholder: "Enter new nickname", text: $userProfileVM.newNickname, isSecure: false, submitLabel: .done, focused: $focusedField, field: 0, onSubmit: {
                    focusedField = nil
                    Task { await userProfileVM.updateProfile(nickname: userProfileVM.newNickname, imageData: userProfileVM.avatarData) }
                })
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onChange(of: userProfileVM.newNickname) { _, newValue in
                    if newValue.count > 15 { userProfileVM.newNickname = String(newValue.prefix(15)) }
                }
                
                // Save Buttons
                Group {
                    switch userProfileVM.saveState {
                    case .idle:
                        AnimatedGradientButton(title: "Save Changes", symbol: "checkmark.seal.fill", gradientColors: animatedGradientButtonColors) {
                            Task { await userProfileVM.updateProfile(nickname: userProfileVM.newNickname, imageData: userProfileVM.avatarData) }
                            focusedField = nil
                        }
                        
                    case .saving:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 24)
                            .padding(.vertical, 12)
                            .background(Color.cyan.opacity(0.2))
                            .cornerRadius(20)
                            .transition(.opacity)
                        
                    case .saved:
                        Label("Saved!", systemImage: "checkmark.circle.fill")
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 24)
                            .padding(.vertical, 12)
                            .background(LinearGradient(colors: [Color.cyan, Color.teal], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(color: Color.cyan.opacity(0.5), radius: 10)
                            .transition(.opacity)
                        
                    case .rejected:
                        Label("Inappropriate avatar!", systemImage: "xmark.octagon.fill")
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 24)
                            .padding(.vertical, 12)
                            .background(LinearGradient(colors: [Color.orange, Color.red], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(color: Color.red.opacity(0.5), radius: 10)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
    
    private var scorePanel: some View {
        EdgeLitContainer {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Performance", subtitle: "Your global standing")
                
                if let error = accountScoreVM.errorMessage {
                    Text(error)
                        .foregroundColor(.orange)
                } else {
                    HStack(alignment: .center, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Highest Score", systemImage: "trophy.fill")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.7))
                            Text("\(accountScoreVM.bestScore ?? 0)")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(LinearGradient(colors: [.white, .cyan], startPoint: .top, endPoint: .bottom))
                                .shadow(color: .cyan.opacity(0.6), radius: 10)
                        }
                        
                        Spacer(minLength: 12)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(LinearGradient(colors: [.white.opacity(0.05), .white.opacity(0.02)], startPoint: .top, endPoint: .bottom))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(LinearGradient(colors: [.cyan.opacity(0.5), .teal.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                            HStack(spacing: 10) {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .font(.system(size: 20))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Rank")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.white.opacity(0.65))
                                    Group {
                                        if let rank = accountScoreVM.globalRank {
                                            Text("#\(rank)")
                                        } else {
                                            Text("-")
                                        }
                                    }
                                    .font(.title3)
                                    .fontWeight(.heavy)
                                    .foregroundStyle(LinearGradient(colors: [.white, .cyan], startPoint: .top, endPoint: .bottom))
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                        }
                        .frame(height: 58)
                    }
                    Divider()
                        .overlay(LinearGradient(colors: [.white.opacity(0.0), .white.opacity(0.25), .white.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
                        .padding(.vertical, 2)

                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                        Text("Tip: Flow rewards balance over force.")
                    }
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
                }
            }
            .overlay(alignment: .topTrailing) {
                FlowDecoration()
                    .opacity(0.15)
                    .padding(.trailing, 8)
                    .padding(.bottom, 6)
                    .accessibilityHidden(true)
            }
        }
    }
    
    private var preferencesPanel: some View {
        EdgeLitContainer {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Preferences", subtitle: "Audio settings")
                
                VStack(spacing: 12) {
                    Toggle(isOn: Binding(
                        get: { userProfileVM.appState.currentUserProfile?.musicEnabled ?? true },
                        set: { newValue in
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
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
                        .tint(.cyan)
                    
                    
                    Toggle(isOn: Binding(
                        get: { userProfileVM.appState.currentUserProfile?.sfxEnabled ?? true },
                        set: { newValue in
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
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
                        .tint(.cyan)
                }
            }
        }
    }

    private var actionsPanel: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { signOutButtonPressed = true }
                    try? await Task.sleep(nanoseconds: 150_000_000)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { signOutButtonPressed = false }
                    activeAlert = .signOut
                }
            }) {
                OutlineActionButtonLabel(
                    title: "Sign Out",
                    systemImage: "rectangle.portrait.and.arrow.right",
                    gradient: [.cyan, .teal]
                )
            }
            .scaleEffect(signOutButtonPressed ? 0.94 : 1.0)
            .padding(.horizontal, 35)
            
            Button(action: {
                Task {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { deleteButtonPressed = true }
                    try? await Task.sleep(nanoseconds: 150_000_000)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { deleteButtonPressed = false }
                    activeAlert = .deleteAccount
                }
            }) {
                Label("Delete Account", systemImage: "trash.fill")
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.red]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .scaleEffect(deleteButtonPressed ? 0.94 : 1.0)
            }
            .padding(.horizontal, 65)
        }
    }
}

#if DEBUG
#Preview {
    let appState = AppState()
    let userProfileVM = ProfileViewModel(appState: appState, profileService: ProfileService())
    let authVM = AuthViewModel(appState: appState, authService: AuthService())
    let accountScoreVM = AccountScoreViewModel(appState: appState, scoreService: ScoreService())
    
    ProfileView(authVM: authVM, userProfileVM: userProfileVM, accountScoreVM: accountScoreVM)
        .environmentObject(appState)
}
#endif

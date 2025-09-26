//
//  EndGameView.swift
//  Flowt
//
//  Created by Wiktor Drab on 24/09/2025.
//

import SwiftUI

struct EndGameView: View {
    @ObservedObject var gameVM: GameViewModel
    @ObservedObject var scoreVM: ScoreViewModel
    
    var body: some View {
        ZStack {
            BackgroundView()
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer(minLength: 20)
                
                // Wynik gracza
                VStack(spacing: 8) {
                    Text("Your Score")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(scoreVM.score ?? 0)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    if let rank = scoreVM.userRank {
                        Text("Score Rank: #\(rank)")
                            .font(.title3)
                            .foregroundColor(.yellow)
                            .padding(.top, 4)
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 8)
                .padding(.horizontal)
                
                // Błędy
                if let error = scoreVM.errorMessage {
                    Text(error)
                        .foregroundColor(.yellow)
                        .font(.callout)
                        .padding(.horizontal)
                }
                
                // Leaderboard
                List {
                    Section(header: Text("Top 5").foregroundColor(.white)) {
                        ForEach(Array(scoreVM.leaderboard.enumerated()), id: \.element.entry.id) { index, item in
                            let entry = item.entry
                            let profile = item.profile
                            
                            HStack(spacing: 12) {
                                Text("#\(index + 1)")
                                    .frame(width: 32, alignment: .leading)
                                    .foregroundColor(.yellow)
                                
                                Group {
                                    if let base64 = profile?.avatarBase64, let data = Data(base64Encoded: base64), let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                    } else {
                                        Image("FlowtLogo")
                                            .resizable()
                                    }
                                }
                                .scaledToFill()
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                
                                Text(profile?.nickname ?? "Unknown")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("\(entry.score)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 6)
                            .listRowBackground(
                                item.isLatest ? Color.yellow.opacity(0.4) :
                                item.isCurrentUser ? Color.blue.opacity(0.25) :
                                Color.clear
                            )
                        }
                    }
                }
                .scrollContentBackground(.hidden) // usuwa domyślne tło listy
                .background(Color.clear) // pozwala pokazać BackgroundView
                .frame(maxHeight: 400) // żeby lista nie zajmowała całego ekranu
                
                Spacer()
                
                // Powrót do menu
                Button(action: { gameVM.backToMenu() }) {
                    Text("Back to Menu")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .gradientBackground()
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
            .task { await scoreVM.saveAndLoadLeaderboard(limit: 5) }
        }
    }
}

#Preview {
    let appState = AppState()
    EndGameView(gameVM: GameViewModel(), scoreVM: ScoreViewModel(appState: appState, scoreService: ScoreService(), profileService: UserProfileService()))
        .environmentObject(appState)
}

//
//  LeaderboardView.swift
//  Flowt
//
//  Created by Wiktor Drab on 25/09/2025.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var scoreVM: ScoreViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Leaderboard")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .padding(.top, 24)
            
            if let error = scoreVM.errorMessage {
                Text(error)
                    .foregroundColor(.yellow)
                    .font(.callout)
                    .padding(.horizontal)
            }
            
            if scoreVM.isLoading == true {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                List {
                    Section(header: Text("Top 100").foregroundColor(.white)) {
                        ForEach(Array(scoreVM.leaderboard.enumerated()), id: \.element.entry.id) { index, item in
                            let entry = item.entry
                            let profile = item.profile
                            
                            HStack(spacing: 12) {
                                Text("#\(index + 1)")
                                    .font(.headline)
                                    .foregroundColor(colorForRank(index + 1))
                                    .frame(width: 40, alignment: .leading)
                                
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
                            .listRowBackground(item.isCurrentUser ? Color.blue.opacity(0.25) : Color.clear)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .background(Color.clear)
        .task { await scoreVM.loadLeaderboard(limit: 100) }
    }
    
    private func colorForRank(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .white
        }
    }
}

#Preview {
    let appState = AppState()
    LeaderboardView(scoreVM: ScoreViewModel(appState: appState, scoreService: ScoreService(), profileService: ProfileService()))
}

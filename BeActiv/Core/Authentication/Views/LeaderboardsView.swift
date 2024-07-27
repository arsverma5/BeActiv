//
//  LeaderboardsView.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/8/24.
//

import SwiftUI
import FirebaseAuth

struct LeaderboardsView: View {
    @State private var selectedTab = 0
    @StateObject private var viewModel = LeaderboardsViewModel()
    private var loggedInUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Button(action: {
                    selectedTab = 0
                }) {
                    Text("Steps Leaderboard")
                        .foregroundColor(selectedTab == 0 ? .white : .blue)
                        .padding()
                        .background(selectedTab == 0 ? Color.blue : Color.clear)
                        .clipShape(Capsule())
                }
                .padding(.trailing, 5)
                
                Button(action: {
                    selectedTab = 1
                }) {
                    Text("Challenges Leaderboard")
                        .foregroundColor(selectedTab == 1 ? .white : .blue)
                        .padding()
                        .background(selectedTab == 1 ? Color.blue : Color.clear)
                        .clipShape(Capsule())
                }
                .padding(.leading, 5)
            }
            .padding(.horizontal, 20)
            
            if selectedTab == 0 {
                LeaderboardView(leaderboardEntries: viewModel.stepsLeaderboardEntries, loggedInUserId: loggedInUserId ?? "")
            } else {
                ChallengesLeaderboardView(leaderboardEntries: viewModel.challengesLeaderboardEntries, loggedInUserId: loggedInUserId ?? "")
            }
            
            Spacer()
        }
        .padding(.top, 20)
        .onAppear {
            viewModel.fetchLeaderboardData()
        }
    }
}

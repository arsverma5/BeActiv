//
//  MainView.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var leaderboardsViewModel = LeaderboardsViewModel()

    var body: some View {
        TabView {
            HealthView()
                .tabItem {
                    Label("Steps", systemImage: "figure.walk")
                }
            ChallengesView()
                .tabItem {
                    Label("Challenges", systemImage: "flag")
                }
                .environmentObject(ChallengesViewModel())
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
                .environmentObject(FriendsViewModel())
            LeaderboardsView()
                .tabItem {
                    Label("Leaderboards", systemImage: "list.star")
                }
                .environmentObject(leaderboardsViewModel) // Provide LeaderboardsViewModel
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .environmentObject(viewModel) // Provide AuthViewModel
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
        .environmentObject(LeaderboardsViewModel())
}

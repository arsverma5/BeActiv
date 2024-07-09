//
//  MainView.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: AuthViewModel

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
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
}



//
//  ContentView.swift
//  BeActiv
//
//  Created by Arshia Verma on 6/27/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var leaderboardsViewModel = LeaderboardsViewModel() // StateObject for the main ContentView

    var body: some View {
        Group {
            if viewModel.userSession != nil {
                MainView()
                    .environmentObject(leaderboardsViewModel) // Provide LeaderboardsViewModel here
            } else {
                LoginView()
            }
        }
        .onAppear {
            if viewModel.userSession != nil {
                leaderboardsViewModel.fetchLeaderboardData() // Fetch data when the view appears
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
            .environmentObject(LeaderboardsViewModel())
    }
}

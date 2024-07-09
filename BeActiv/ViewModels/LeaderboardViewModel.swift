//
//  LeaderboardViewModel.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/8/24.
//

import SwiftUI

class LeaderboardViewModel: ObservableObject {
    @Published var leaderboardEntries: [Leaderboard] = []

    // Function to load leaderboard entries from Firebase or other source
    func loadLeaderboard() {
        // Implement logic to fetch data and populate leaderboardEntries
        // Example:
        leaderboardEntries = [
            Leaderboard(username: "User1", stepsCount: 12000),
            Leaderboard(username: "User2", stepsCount: 11000),
            Leaderboard(username: "User3", stepsCount: 10500)
            // Add more entries as needed
        ]
    }
}


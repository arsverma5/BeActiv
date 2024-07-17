//
//  ChallengesLeaderboardViewModel.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/8/24.
//

import SwiftUI

class ChallengesLeaderboardViewModel: ObservableObject {
    @Published var leaderboardEntries: [ChallengesLeaderboard] = []

    // Function to load leaderboard entries from Firebase or other source
    func loadLeaderboard() {
        // Implement logic to fetch data and populate leaderboardEntries
        // Example:
        leaderboardEntries = [
            ChallengesLeaderboard(username: "User1", challengesWon: 5),
            ChallengesLeaderboard(username: "User2", challengesWon: 4),
            ChallengesLeaderboard(username: "User3", challengesWon: 3)
            // Add more entries as needed
        ]
    }
}

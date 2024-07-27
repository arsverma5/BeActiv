
//
//  ChallengesLeaderboardView.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/8/24.
//
import SwiftUI

struct ChallengesLeaderboardView: View {
    var leaderboardEntries: [FriendLeaderboard]
    var loggedInUserId: String

    var body: some View {
        VStack {
            Text("Challenges Leaderboard")
                .font(.title)
                .padding()

            // Display leaderboard entries with gold, silver, and bronze for top 3
            ForEach(leaderboardEntries.indices, id: \.self) { index in
                HStack {
                    Text("\(index + 1)")
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    Text(leaderboardEntries[index].username)
                        .padding(.horizontal)
                    Spacer()
                    Text("\(leaderboardEntries[index].challengesWon) challenges won")
                        .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(backgroundColor(for: index)) // Set background color based on rank
                .cornerRadius(10)
                .padding(.horizontal)
                .overlay(
                    // Highlight logged-in user with special styling
                    leaderboardEntries[index].id == loggedInUserId ?
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                        .padding(.horizontal)
                    : nil
                )
            }
        }
    }

    // Function to return the background color based on the index
    private func backgroundColor(for index: Int) -> Color {
        switch index {
        case 0:
            return .gold // Gold for 1st place
        case 1:
            return .silver // Silver for 2nd place
        case 2:
            return .bronze // Bronze for 3rd place
        default:
            return .clear // No color for other places
        }
    }
}

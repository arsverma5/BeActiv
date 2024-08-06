
//
//  ChallengesLeaderboardView.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/8/24.
//
import SwiftUI

struct ChallengesLeaderboardView: View {
    var leaderboardEntries: [(rank: Int, user: FriendLeaderboard)]
    var loggedInUserId: String

    var body: some View {
        VStack {
            Text("Challenges Won Leaderboard")
                .font(.title)
                .padding()

            ForEach(leaderboardEntries.indices, id: \.self) { index in
                HStack {
                    Text("\(leaderboardEntries[index].rank)")
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    Text(leaderboardEntries[index].user.username)
                        .padding(.horizontal)
                    Spacer()
                    Text("\(leaderboardEntries[index].user.challengesWon) challenges won")
                        .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(backgroundColor(for: leaderboardEntries[index].rank))
                .cornerRadius(10)
                .padding(.horizontal)
                .overlay(
                    leaderboardEntries[index].user.id == loggedInUserId ?
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                        .padding(.horizontal)
                    : nil
                )
            }
        }
        .onAppear {
            print("Logged In User ID: \(loggedInUserId)")
            print("Leaderboard Entries: \(leaderboardEntries)")
        }
    }

    private func backgroundColor(for rank: Int) -> Color {
        switch rank {
        case 1:
            return .gold
        case 2:
            return .silver
        case 3:
            return .bronze
        default:
            return .clear
        }
    }
}

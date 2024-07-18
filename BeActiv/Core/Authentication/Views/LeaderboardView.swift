//
//  LeaderboardView.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/8/24.
//
import SwiftUI

struct LeaderboardView: View {
    var leaderboardEntries: [FriendLeaderboard]

    var body: some View {
        VStack {
            Text("Steps Walked Leaderboard")
                .font(.title)
                .padding()

            // Display leaderboard entries with medals for top 3
            ForEach(leaderboardEntries.indices, id: \.self) { index in
                HStack {
                    Text("\(index + 1)")
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    Text(leaderboardEntries[index].username)
                        .padding(.horizontal)
                    Spacer()
                    Text("\(leaderboardEntries[index].steps) steps")
                        .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(index < 3 ?
                                (index == 0 ? Color.yellow : (index == 1 ? Color.gray : Color.orange)) :
                                Color.clear)
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }
}


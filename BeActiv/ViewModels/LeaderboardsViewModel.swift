//
//  LeaderboardsViewModel.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/8/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class LeaderboardsViewModel: ObservableObject {
    @Published var friends: [FriendLeaderboard] = []
    @Published var stepsLeaderboardEntries: [FriendLeaderboard] = []
    @Published var challengesLeaderboardEntries: [FriendLeaderboard] = []

    private var db = Firestore.firestore()

    init() {
        fetchFriends()
    }

    func fetchFriends() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        let friendsRef = db.collection("users").document(userID).collection("friends")

        friendsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching friends: \(error.localizedDescription)")
                self.retryFetchFriends()
                return
            }

            guard let documents = snapshot?.documents else {
                print("No friends found for user.")
                return
            }

            self.friends = documents.compactMap { doc -> FriendLeaderboard? in
                try? doc.data(as: FriendLeaderboard.self)
            }

            self.stepsLeaderboardEntries = self.friends.sorted { $0.steps > $1.steps }
            self.challengesLeaderboardEntries = self.friends.sorted { $0.challengesWon > $1.challengesWon }
        }
    }

    private func retryFetchFriends() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            print("Retrying to fetch friends...")
            self.fetchFriends()
        }
    }
}



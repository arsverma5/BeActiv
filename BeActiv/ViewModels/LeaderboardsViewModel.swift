import FirebaseFirestore
import FirebaseAuth

class LeaderboardsViewModel: ObservableObject {
    @Published var stepsLeaderboardEntries: [(rank: Int, user: FriendLeaderboard)] = []
    @Published var challengesLeaderboardEntries: [(rank: Int, user: FriendLeaderboard)] = []

    private var db = Firestore.firestore()

    func fetchLeaderboardData() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        let userRef = db.collection("users").document(userID)
        let friendsRef = userRef.collection("friends")

        // Fetch friends' IDs
        friendsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching friends: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No friends found for user.")
                return
            }

            // Collect all friend IDs
            let friendIDs = documents.map { $0.documentID }

            // Include the logged-in user's ID
            let allUserIDs = friendIDs + [userID]

            // Fetch data for all users in a single Firestore query using 'in' clause
            self.fetchMultipleUsersData(userIDs: allUserIDs) { friends in
                // Sort and rank
                self.stepsLeaderboardEntries = self.rankLeaderboard(friends: friends, keyPath: \.steps)
                self.challengesLeaderboardEntries = self.rankLeaderboard(friends: friends, keyPath: \.challengesWon)

                print("Steps Leaderboard Entries: \(self.stepsLeaderboardEntries)")
                print("Challenges Leaderboard Entries: \(self.challengesLeaderboardEntries)")
            }
        }
    }

    private func fetchMultipleUsersData(userIDs: [String], completion: @escaping ([FriendLeaderboard]) -> Void) {
        db.collection("users")
            .whereField(FieldPath.documentID(), in: userIDs)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching users data: \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No user data found.")
                    completion([])
                    return
                }

                // Map documents to FriendLeaderboard objects
                let friends = documents.compactMap { document -> FriendLeaderboard? in
                    let data = document.data()

                    return FriendLeaderboard(
                        id: document.documentID,
                        username: data["fullName"] as? String ?? "Unknown",
                        steps: data["stepCount"] as? Int ?? 0,
                        challengesWon: data["challengesWon"] as? Int ?? 0
                    )
                }


                completion(friends)
            }
    }

    private func rankLeaderboard(friends: [FriendLeaderboard], keyPath: KeyPath<FriendLeaderboard, Int>) -> [(rank: Int, user: FriendLeaderboard)] {
        let sortedFriends = friends.sorted { $0[keyPath: keyPath] > $1[keyPath: keyPath] }

        var rankedFriends = [(rank: Int, user: FriendLeaderboard)]()
        var currentRank = 1
        var previousValue = -1

        for (index, friend) in sortedFriends.enumerated() {
            let currentValue = friend[keyPath: keyPath]
            if currentValue != previousValue {
                currentRank = index + 1
            }
            rankedFriends.append((rank: currentRank, user: friend))
            previousValue = currentValue
        }

        return rankedFriends
    }
}

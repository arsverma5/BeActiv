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

        // Fetch friends' data
        friendsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching friends: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No friends found for user.")
                return
            }

            var friends = [FriendLeaderboard]()
            let dispatchGroup = DispatchGroup()

            for doc in documents {
                let friendID = doc.documentID
                dispatchGroup.enter()
                self.fetchSpecificUserData(userID: friendID) { friend in
                    if let friend = friend {
                        friends.append(friend)
                    }
                    dispatchGroup.leave()
                }
            }

            // Fetch logged-in user's data
            dispatchGroup.enter()
            self.fetchSpecificUserData(userID: userID) { loggedInUser in
                if let loggedInUser = loggedInUser {
                    friends.append(loggedInUser)
                }
                dispatchGroup.leave()
            }

            dispatchGroup.notify(queue: .main) {
                // Sort and rank
                self.stepsLeaderboardEntries = self.rankLeaderboard(friends: friends, keyPath: \.steps)
                self.challengesLeaderboardEntries = self.rankLeaderboard(friends: friends, keyPath: \.challengesWon)

                print("Steps Leaderboard Entries: \(self.stepsLeaderboardEntries)")
                print("Challenges Leaderboard Entries: \(self.challengesLeaderboardEntries)")
            }
        }
    }

    private func fetchSpecificUserData(userID: String, completion: @escaping (FriendLeaderboard?) -> Void) {
        let userRef = db.collection("users").document(userID)

        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user data for \(userID): \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = document?.data() else {
                print("No data found for user ID \(userID)")
                completion(nil)
                return
            }

            let friend = FriendLeaderboard(
                id: userID,
                username: data["fullName"] as? String ?? "Unknown",
                steps: data["stepCount"] as? Int ?? 0,
                challengesWon: data["challengesWon"] as? Int ?? 0
            )
            completion(friend)
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

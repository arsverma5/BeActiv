import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class LeaderboardsViewModel: ObservableObject {
    @Published var stepsLeaderboardEntries: [FriendLeaderboard] = []
    @Published var challengesLeaderboardEntries: [FriendLeaderboard] = []

    private var db = Firestore.firestore()

    func fetchLeaderboardData() {
         guard let userID = Auth.auth().currentUser?.uid else {
             print("User not logged in.")
             return
         }

         let userRef = db.collection("users").document(userID)
         let friendsRef = userRef.collection("friends")

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

             var friends = documents.compactMap { doc -> FriendLeaderboard? in
                 let data = doc.data()
                 print("Raw friend data: \(data)") // Print raw data
                 let username = data["name"] as? String ?? "Unknown"
                 let steps = data["stepCount"] as? Int ?? 0
                 let challengesWon = data["challengesWon"] as? Int ?? 0
                 return FriendLeaderboard(id: doc.documentID, username: username, steps: steps, challengesWon: challengesWon)
             }

             userRef.getDocument { (document, error) in
                 if let error = error {
                     print("Error fetching user data: \(error.localizedDescription)")
                     return
                 }

                 guard let data = document?.data() else {
                     print("User data not found.")
                     return
                 }

                 print("Raw user data: \(data)") // Print raw data
                 let username = data["fullName"] as? String ?? "Unknown" // Corrected field name
                 let steps = data["stepCount"] as? Int ?? 0
                 let challengesWon = data["challengesWon"] as? Int ?? 0
                 let loggedInUser = FriendLeaderboard(id: userID, username: username, steps: steps, challengesWon: challengesWon)

                 friends.append(loggedInUser)

                 self.stepsLeaderboardEntries = friends.sorted { $0.steps > $1.steps }
                 self.challengesLeaderboardEntries = friends.sorted { $0.challengesWon > $1.challengesWon }

                 print("Steps Leaderboard Entries: \(self.stepsLeaderboardEntries)")
                 print("Challenges Leaderboard Entries: \(self.challengesLeaderboardEntries)")
             }
         }
     }

    private func retryFetchFriends() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            print("Retrying to fetch friends...")
            self.fetchLeaderboardData()
        }
    }
}

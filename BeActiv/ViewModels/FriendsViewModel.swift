import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class FriendsViewModel: ObservableObject {
    @Published var friends: [Friends] = []
    @Published var friendRequests: [FriendRequest] = []
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var currentUser: User?
    @Published var searchResults: [User] = []
    @Published var searchErrorMessage: String? = nil

    init() {
        fetchCurrentUser()
    }

    func fetchCurrentUser() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).getDocument { (document, error) in
            if let document = document, document.exists {
                self.currentUser = try? document.data(as: User.self)
                self.loadFriends()
                self.loadFriendRequests()
            } else {
                print("User does not exist or error fetching user: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func sendFriendRequest(to user: User) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        guard let currentUser = currentUser else {
            showAlert(with: "Failed to fetch current user details")
            return
        }

        let db = Firestore.firestore()
        let friendRequestsRef = db.collection("users").document(user.id!).collection("friendRequests")

        friendRequestsRef.whereField("senderId", isEqualTo: currentUserID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error checking existing friend requests: \(error.localizedDescription)")
                self.showAlert(with: "Failed to check existing friend requests")
                return
            }

            if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                self.showAlert(with: "Friend request already sent to this user")
                return
            }

            let newRequest = FriendRequest(senderId: currentUserID, senderName: currentUser.fullName, receiverId: user.id!, receiverName: user.fullName)

            do {
                let _ = try friendRequestsRef.addDocument(from: newRequest)
                self.showAlert(with: "Friend request sent to \(user.fullName)")
            } catch {
                self.showAlert(with: "Failed to send friend request")
                print("Error sending friend request: \(error.localizedDescription)")
            }
        }
    }

    func acceptFriendRequest(_ request: FriendRequest) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let newFriend = Friends(name: request.senderName, imageName: "person.circle.fill")
        friends.append(newFriend)
        saveFriendsToFirestore(newFriend)

        removeFriendRequest(request)
        // Update other parts of the app, like the leaderboard
        updateLeaderboard()
    }

    func declineFriendRequest(_ request: FriendRequest) {
        removeFriendRequest(request)
    }

    private func removeFriendRequest(_ request: FriendRequest) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).collection("friendRequests").document(request.id!).delete { error in
            if let error = error {
                print("Error deleting friend request: \(error.localizedDescription)")
            } else {
                print("Friend request removed from Firestore")
            }
        }
    }

    func loadFriendRequests() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).collection("friendRequests").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching friend requests: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.friendRequests = documents.compactMap { document -> FriendRequest? in
                try? document.data(as: FriendRequest.self)
            }
        }
    }

    func searchFriend(by name: String) async -> [User] {
        var foundUsers: [User] = []

        guard let currentUser = currentUser else {
            print("Current user's name not available.")
            return []
        }

        let db = Firestore.firestore()
        let querySnapshot = try? await db.collection("users")
            .whereField("fullName", isEqualTo: name)
            .getDocuments()

        if let documents = querySnapshot?.documents {
            foundUsers = documents.compactMap { document -> User? in
                let user = try? document.data(as: User.self)
                return user?.fullName == currentUser.fullName ? nil : user
            }
        }

        if foundUsers.isEmpty {
            searchErrorMessage = "This person does not exist. Try again."
        } else {
            searchErrorMessage = nil
        }

        return foundUsers
    }

    func addFriend(_ user: User) {
        if friends.contains(where: { $0.name == user.fullName }) {
            showAlert(with: "You are already friends with this person")
            return
        }

        let newFriend = Friends(name: user.fullName, imageName: "person.circle.fill")
        friends.append(newFriend)
        saveFriendsToFirestore(newFriend)
        // Update other parts of the app, like the leaderboard
        updateLeaderboard()
    }

    func loadFriends() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).collection("friends").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting friends: \(error)")
                return
            }

            self.friends = querySnapshot?.documents.compactMap { document -> Friends? in
                let data = document.data()
                guard let name = data["name"] as? String else { return nil }
                return Friends(name: name, imageName: "person.circle.fill")
            } ?? []
        }
    }

    private func saveFriendsToFirestore(_ friend: Friends) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let friendData: [String: Any] = ["name": friend.name]
        db.collection("users").document(currentUserID).collection("friends").document(friend.name).setData(friendData) { error in
            if let error = error {
                print("Error saving friend: \(error)")
            }
        }
    }

    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }

    func removeFriend(_ friend: Friends) {
        removeFriendFromDatabase(friend) { [weak self] success in
            if success {
                if let index = self?.friends.firstIndex(where: { $0.name == friend.name }) {
                    self?.friends.remove(at: index)
                    // Update other parts of the app, like the leaderboard
                    self?.updateLeaderboard()
                }
            } else {
                self?.alertMessage = "Failed to remove friend."
                self?.showAlert = true
            }
        }
    }

    private func removeFriendFromDatabase(_ friend: Friends, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("friends").document(friend.name).delete { error in
            if let error = error {
                print("Error removing friend: \(error)")
                completion(false)
            } else {
                print("Friend removed successfully")
                completion(true)
            }
        }
    }

    private func updateLeaderboard() {
        // Code to update the leaderboard
        // This could involve notifying other parts of your app to refresh their data
    }
}

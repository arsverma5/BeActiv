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

    // Fetch current user data
    func fetchCurrentUser() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                self?.currentUser = try? document.data(as: User.self)
                self?.loadFriends()
                self?.loadFriendRequests()
            } else {
                print("User does not exist or error fetching user: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func sendFriendRequest(to user: User) {
        guard let currentUserID = Auth.auth().currentUser?.uid, let currentUser = currentUser else {
            showAlert(with: "Failed to fetch current user details")
            return
        }

        // Check if already friends
        if friends.contains(where: { $0.name == user.fullName }) {
            showAlert(with: "You are already friends with \(user.fullName)")
            return
        }

        let db = Firestore.firestore()
        let friendRequestsRef = db.collection("users").document(user.id!).collection("friendRequests")

        friendRequestsRef.whereField("senderId", isEqualTo: currentUserID).getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error checking existing friend requests: \(error.localizedDescription)")
                self?.showAlert(with: "Failed to check existing friend requests")
                return
            }

            if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                self?.showAlert(with: "Friend request already sent to this user")
                return
            }

            let newRequest = FriendRequest(senderId: currentUserID, senderName: currentUser.fullName, receiverId: user.id!, receiverName: user.fullName)

            do {
                let _ = try friendRequestsRef.addDocument(from: newRequest)
                self?.showAlert(with: "Friend request sent to \(user.fullName)")
            } catch {
                self?.showAlert(with: "Failed to send friend request")
                print("Error sending friend request: \(error.localizedDescription)")
            }
        }
    }


    private func showAlert(with message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showAlert = true
            print("Alert Message: \(message)")  // Debug statement
            print("Show Alert: \(self.showAlert)")  // Debug statement
        }
    }

    func acceptFriendRequest(_ request: FriendRequest) {
        print("Accept button action confirmed for \(request.senderName)")
        print("Request ID: \(request.id ?? "Unknown")")
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let currentUserFriend = Friends(name: request.senderName, imageName: "person.circle.fill")
        let senderFriend = Friends(name: currentUser?.fullName ?? "", imageName: "person.circle.fill")

        addFriend(currentUserFriend)
        addFriendToUser(userId: request.senderId, friend: senderFriend)
        removeFriendRequest(request)
        updateLeaderboard()
    }

    private func addFriendToUser(userId: String, friend: Friends) {
        print("Adding friend \(friend.name) to user \(userId)")
        let db = Firestore.firestore()
        let friendData: [String: Any] = ["name": friend.name]

        db.collection("users").document(userId).collection("friends").document(friend.name).setData(friendData) { error in
            if let error = error {
                print("Error saving friend to user \(userId): \(error)")
            } else {
                print("Friend added successfully to user \(userId)")
            }
        }
    }

    func declineFriendRequest(_ request: FriendRequest) {
        print("Decline button action confirmed for \(request.senderName)")
        print("Request ID: \(request.id ?? "Unknown")")
        
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
        db.collection("users").document(currentUserID).collection("friendRequests").addSnapshotListener { [weak self] snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching friend requests: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self?.friendRequests = documents.compactMap { document -> FriendRequest? in
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

        searchErrorMessage = foundUsers.isEmpty ? "This person does not exist. Try again." : nil
        return foundUsers
    }

    func addFriend(_ friend: Friends) {
        if friends.contains(where: { $0.name == friend.name }) {
            showAlert(with: "You are already friends with this person")
            return
        }

        friends.append(friend)
        saveFriendsToFirestore(friend)
        updateLeaderboard()
    }

    func loadFriends() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).collection("friends").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting friends: \(error)")
                return
            }

            self?.friends = querySnapshot?.documents.compactMap { document -> Friends? in
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
            } else {
                print("Friend saved successfully")
            }
        }
    }

    func removeFriend(_ friend: Friends) {
        guard let currentUserID = Auth.auth().currentUser?.uid, let friendID = friend.id else {
            print("Current user ID or friend ID is missing")
            return
        }

        // Remove friend from current user's list
        removeFriendFromDatabase(friend) { [weak self] success in
            if success {
                // Remove friend from current user's local list
                if let index = self?.friends.firstIndex(where: { $0.id == friendID }) {
                    self?.friends.remove(at: index)
                }

                // Also remove the current user from the friend's list
                self?.removeFriendFromUser(currentUserID: currentUserID, friendID: friendID) { success in
                    if success {
                        print("Successfully removed friend from the other user's list")
                        self?.updateLeaderboard()
                    } else {
                        print("Failed to remove friend from the other user's list")
                        self?.alertMessage = "Failed to update friend list for the other user."
                        self?.showAlert = true
                    }
                }
            } else {
                self?.alertMessage = "Failed to remove friend."
                self?.showAlert = true
            }
        }
    }

    private func removeFriendFromDatabase(_ friend: Friends, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).collection("friends").document(friend.id!).delete { error in
            if let error = error {
                print("Error removing friend from current user: \(error)")
                completion(false)
            } else {
                print("Friend removed successfully from current user")
                completion(true)
            }
        }
    }

    private func removeFriendFromUser(currentUserID: String, friendID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(friendID).collection("friends").document(currentUserID).delete { error in
            if let error = error {
                print("Error removing friend from other user's friend list: \(error)")
                completion(false)
            } else {
                print("Friend removed successfully from other user's friend list")
                completion(true)
            }
        }
    }





    private func updateLeaderboard() {
        // Implementation for updating the leaderboard
    }
}

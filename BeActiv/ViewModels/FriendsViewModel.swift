import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class FriendsViewModel: ObservableObject {
    @Published var friends: [Friends] = []
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    func searchFriend(by name: String) async -> [User] {
        var foundUsers: [User] = []

        let db = Firestore.firestore()
        let querySnapshot = try? await db.collection("users")
            .whereField("fullName", isEqualTo: name)
            .getDocuments()

        if let documents = querySnapshot?.documents {
            foundUsers = documents.compactMap { try? $0.data(as: User.self) }
        }

        return foundUsers
    }

    func addFriend(_ user: User) {
        // Check if the friend already exists
        if friends.contains(where: { $0.name == user.fullName }) {
            showAlert(with: "You are already friends with this person")
            return
        }

        let newFriend = Friends(name: user.fullName, imageName: "person.circle.fill")
        friends.append(newFriend)
        saveFriendsToFirestore(newFriend)
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
}

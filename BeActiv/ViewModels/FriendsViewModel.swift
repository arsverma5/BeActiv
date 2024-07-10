//
//  FriendsViewModel.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//

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
        saveFriendsToFirestore()
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

    func saveFriendsToFirestore() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        for friend in friends {
            let friendData: [String: Any] = ["name": friend.name]
            db.collection("users").document(currentUserID).collection("friends").document(friend.id.uuidString).setData(friendData) { error in
                if let error = error {
                    print("Error saving friend: \(error)")
                }
            }
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}


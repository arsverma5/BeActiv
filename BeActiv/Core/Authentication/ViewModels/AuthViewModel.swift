//
//  AuthViewModel.swift
//  BeActiv
//
//  Created by Arshia Verma on 6/30/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth

protocol AuthtenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUserData()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUserData()
        } catch {
            print("Failed to log in with error: \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullName: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id!).setData(encodedUser)
            await fetchUserData() // Refresh user data after creating
        } catch {
            print("Failed to create user with error: \(error.localizedDescription)")
        }
    }
    
    func fetchUserData() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        do {
            let documentSnapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            if documentSnapshot.exists {
                self.currentUser = try? documentSnapshot.data(as: User.self)
                print("Current user: \(String(describing: self.currentUser))")
            } else {
                print("Document does not exist.")
            }
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("Failed to sign out with error: \(error.localizedDescription)")
        }
    }
}

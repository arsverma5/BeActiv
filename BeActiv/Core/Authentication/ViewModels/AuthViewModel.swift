//
//  AuthViewModel.swift
//  BeActiv
//
//  Created by Arshia Verma on 6/30/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol AuthtenticationFormProtocol {
    var formIsValid: Bool { get }
}


@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    
    init() {
        // if current user is logged in firebase caches the information of the user.
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
            print("DEBUG: Failed to log in with error \(error.localizedDescription)")
        }
        
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullName: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUserData()
        } catch {
            print("DEBUG: FAILED TO CREATE USER WITH ERROR \(error.localizedDescription)")
            
        }
        
        
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut() // backend signing out
            self.userSession = nil // wipes out user session and goes back to login
            self.currentUser = nil // wipes out current user object
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
        
        
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUserData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
        print("DEBUG: current user is \(self.currentUser)")
        
    }
}

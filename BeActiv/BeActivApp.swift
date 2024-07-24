//
//  BeActivApp.swift
//  BeActiv
//
//  Created by Arshia Verma on 6/27/24.
//

import SwiftUI
import Firebase

@main
struct BeActivApp: App {
    @StateObject var viewModel = AuthViewModel()
    let challengeManager = ChallengeManager()
    
    init() {
        // Configure Firebase at the very start
        FirebaseApp.configure()
        // Add predefined challenges to Firestore
        challengeManager.addPredefinedChallenges { error in
            if let error = error {
                print("Error adding predefined challenges: \(error.localizedDescription)")
            } else {
                print("Predefined challenges added successfully.")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}


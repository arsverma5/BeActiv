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
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onAppear {
                    // Add predefined challenges on app start
                    challengeManager.addPredefinedChallenges { error in
                        if let error = error {
                            print("Error adding predefined challenges: \(error.localizedDescription)")
                        } else {
                            print("Predefined challenges added successfully.")
                        }
                    }
                }
        }
    }
}

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
                    // Clear and add predefined challenges on app start
                    challengeManager.clearAndAddPredefinedChallenges { error in
                        if let error = error {
                            print("Error resetting challenges: \(error.localizedDescription)")
                        } else {
                            print("Challenges reset successfully.")
                        }
                    }
                }
        }
    }
}

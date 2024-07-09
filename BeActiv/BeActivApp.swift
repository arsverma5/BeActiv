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
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onAppear {
                    // Schedule the timer to add random challenges every 3 days
                    Timer.scheduledTimer(withTimeInterval: 86400 * 3, repeats: true) { _ in
                        challengeManager.addRandomChallenge()
                    }
                }
        }
    }
}

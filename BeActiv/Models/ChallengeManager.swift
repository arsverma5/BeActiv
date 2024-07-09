//
//  ChallengeManager.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/6/24.
//

import Foundation
import FirebaseFirestore

class ChallengeManager {
    private lazy var db = Firestore.firestore() // Lazy initialization
    
    private let predefinedChallenges: [Challenge] = [
        Challenge(title: "Walk 10,000 Steps", description: "Walk 10,000 steps in a day.", icon: "🏃‍♂️", progress: 0.0),
        Challenge(title: "Beat 5 Friends", description: "Have a higher step count than 5 friends.", icon: "🏆", progress: 0.0),
        // Add more predefined challenges here
    ]
    
    func addRandomChallenge() {
        let newChallenge = predefinedChallenges.randomElement()!
        db.collection("challenges").addDocument(data: [
            "title": newChallenge.title,
            "description": newChallenge.description,
            "icon": newChallenge.icon,
            "progress": newChallenge.progress,
            "isCompleted": newChallenge.isCompleted
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
            }
        }
    }
}



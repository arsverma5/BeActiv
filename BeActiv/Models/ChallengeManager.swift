//
//  ChallengeManager.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/6/24.
//

import Foundation
import FirebaseFirestore

class ChallengeManager {
    private lazy var db = Firestore.firestore()
    
    private let predefinedChallenges: [Challenge] = [
        Challenge(title: "Walk 10,000 Steps", description: "Walk 10,000+ steps everyday for an entire week.", icon: "🏃‍♂️", progress: 0.0),
        Challenge(title: "Beat 5 Friends", description: "Have a higher step count than 5 friends.", icon: "🏆", progress: 0.0),
        // Add more predefined challenges here
    ]
    
    func addPredefinedChallenges() {
        // Clear existing challenges
        db.collection("challenges").getDocuments { [self] snapshot, error in
            if let error = error {
                print("Error getting challenges: \(error.localizedDescription)")
                return
            }
            
            for document in snapshot?.documents ?? [] {
                document.reference.delete()
            }
            
            // Add predefined challenges
            for challenge in predefinedChallenges {
                var challengeData: [String: Any] = [
                    "title": challenge.title,
                    "description": challenge.description,
                    "icon": challenge.icon,
                    "progress": challenge.progress,
                    "isCompleted": challenge.isCompleted
                ]
                
                if let startDate = challenge.startDate {
                    challengeData["startDate"] = startDate
                }
                
                if let endDate = challenge.endDate {
                    challengeData["endDate"] = endDate
                }
                
                challengeData["dailyStepCounts"] = challenge.dailyStepCounts
                
                db.collection("challenges").addDocument(data: challengeData) { error in
                    if let error = error {
                        print("Error adding challenge: \(error.localizedDescription)")
                    } else {
                        print("Challenge added successfully: \(challenge.title)")
                    }
                }
            }
        }
    }

}


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
        Challenge(title: "Walk 10,000+ Steps", description: "Walk 10,000+ steps everyday for an entire week.", icon: "🚶", progress: 0.0),
        Challenge(title: "Beat 5 Friends", description: "Have a higher step count than 5 friends.", icon: "🏆", progress: 0.0),
        Challenge(title: "Walk 15,000+ Steps", description: "Walk 15,000+ steps everyday for an entire week.", icon: "🏃‍♂️", progress: 0.0),
        Challenge(title: "Walk 20,000+ Steps", description: "Walk 20,000+ steps everyday for three days.", icon: "🏃", progress: 0.0),
        Challenge(title: "Participate in 3 different challenges", description: "Complete 3 challenges!", icon: "🏆", progress: 0.0),
        Challenge(title: "Winner Winner Chicken Dinner #1", description: "Get the gold medal on the steps leaderboard 3 times", icon: "🏆", progress: 0.0),
        Challenge(title: "Winner Winner Chicken Dinner #2", description: "Get the gold medal on the challenges leaderboard 3 times", icon: "🏆", progress: 0.0)
        // Add more predefined challenges here
    ]
    
    func addPredefinedChallenges(completion: @escaping (Error?) -> Void) {
        db.collection("challenges").getDocuments { [weak self] snapshot, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let documents = snapshot?.documents, documents.isEmpty else {
                completion(nil)
                return
            }
            
            let batch = self?.db.batch()
            self?.predefinedChallenges.forEach { challenge in
                let document = self?.db.collection("challenges").document()
                do {
                    try batch?.setData(from: challenge, forDocument: document!)
                } catch {
                    print("Error adding challenge: \(error.localizedDescription)")
                }
            }
            
            batch?.commit { error in
                if let error = error {
                    print("Error committing batch: \(error.localizedDescription)")
                } else {
                    print("Successfully added predefined challenges.")
                }
                completion(error)
            }
        }
    }
}

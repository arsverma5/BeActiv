//
//  Challenges.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//

import Foundation
import FirebaseFirestoreSwift

struct Challenge: Identifiable, Codable {
    @DocumentID var id: String? // Optional String to hold the document ID from Firestore
    let title: String
    let description: String
    let icon: String
    var progress: Double
    var isCompleted: Bool = false
    var startDate: Date? // will track when the user wants to start the challenge
    var endDate: Date? // will track when the challenge ends
    var dailyStepCounts: [String: Int] = [:] // dict to store daily step counts
}









//
//  Challenges.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//

import Foundation
import FirebaseFirestoreSwift

struct Challenge: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let description: String
    let icon: String
    var progress: Double // Progress between 0.0 and 1.0
    var isCompleted: Bool = false
    var startDate: Date?
    var endDate: Date?
    var dailyStepCounts: [String: Int] = [:]
    
    init(
        id: String? = nil,
        title: String,
        description: String,
        icon: String,
        progress: Double = 0.0,
        isCompleted: Bool = false,
        startDate: Date? = nil,
        endDate: Date? = nil,
        dailyStepCounts: [String: Int] = [:]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.progress = progress
        self.isCompleted = isCompleted
        self.startDate = startDate
        self.endDate = endDate
        self.dailyStepCounts = dailyStepCounts
    }
}


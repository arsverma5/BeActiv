//
//  FriendLeaderboard.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/8/24.
//

import Foundation
import FirebaseFirestoreSwift

struct FriendLeaderboard: Identifiable, Codable {
    @DocumentID var id: String?
    let username: String
    let steps: Int
    let challengesWon: Int

    init(id: String? = nil, username: String, steps: Int = 0, challengesWon: Int = 0) {
        self.id = id
        self.username = username
        self.steps = steps
        self.challengesWon = challengesWon
    }

    enum CodingKeys: String, CodingKey {
        case id
        case username = "fullName" // Update field name as per your Firestore schema
        case steps = "stepCount"
        case challengesWon
    }
}

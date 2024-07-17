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
}

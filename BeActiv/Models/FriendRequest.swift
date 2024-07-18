//
//  FriendRequest.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/18/24.
//

import Foundation
import FirebaseFirestoreSwift

struct FriendRequest: Identifiable, Codable {
    @DocumentID var id: String?
    let senderId: String
    let senderName: String
    let receiverId: String
    let receiverName: String
}

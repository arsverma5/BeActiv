//
//  FriendsViewModel.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//

import SwiftUI

class FriendsViewModel : ObservableObject {
    @Published var friends: [Friends] = [
        Friends(name: "Michael", stepCount: 12000, imageName: "person.circle.fill"),
        Friends(name: "Kobe", stepCount: 15000, imageName: "person.circle.fill"),
        Friends(name: "Kareem", stepCount: 9000, imageName: "person.circle.fill")
    ]
    
    func addFriend(_ name: String) {
        let newFriend = Friends(name: name, stepCount: Int.random(in: 5000...30000), imageName: "person.circle.fill") // Simulated and needs to change
        friends.append(newFriend)
    }
}

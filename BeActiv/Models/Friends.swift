//
//  Friends.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//
import Foundation
import FirebaseFirestoreSwift

struct Friends: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var imageName: String
    
    init(id: String? = nil, name: String, imageName: String) {
        self.id = id
        self.name = name
        self.imageName = imageName
    }
}


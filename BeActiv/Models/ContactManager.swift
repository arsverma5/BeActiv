//
//  ContactManager.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/6/24.
//

// ContactManager.swift
import Contacts
import SwiftUI

class ContactManager: ObservableObject {
    @Published var contacts: [CNContact] = []
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func fetchContacts(completion: @escaping ([CNContact]) -> Void) {
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        var contacts: [CNContact] = []
        do {
            try store.enumerateContacts(with: request) { contact, stop in
                contacts.append(contact)
            }
            DispatchQueue.main.async {
                completion(contacts)
            }
        } catch {
            print("Failed to fetch contacts: \(error)")
            DispatchQueue.main.async {
                completion([])
            }
        }
    }
}



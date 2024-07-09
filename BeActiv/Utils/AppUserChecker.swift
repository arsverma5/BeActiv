//
//  AppUserChecker.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/7/24.
//

import Foundation
import Contacts

class AppUserChecker {
    func checkAppUsers(contacts: [CNContact], completion: @escaping ([CNContact]) -> Void) {
        // Extract phone numbers from contacts
        let phoneNumbers = contacts.flatMap { $0.phoneNumbers.map { $0.value.stringValue } }
        
        // Query backend to check which numbers are users of the app
        // Assuming you have an API endpoint that accepts phone numbers and returns registered users
        
        let url = URL(string: "https://your-backend.com/check-app-users")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["phoneNumbers": phoneNumbers]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                let registeredNumbers = try JSONDecoder().decode([String].self, from: data)
                let registeredContacts = contacts.filter { contact in
                    contact.phoneNumbers.contains { registeredNumbers.contains($0.value.stringValue) }
                }
                DispatchQueue.main.async {
                    completion(registeredContacts)
                }
            } catch {
                print("Failed to decode response:", error)
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
        
        task.resume()
    }
}


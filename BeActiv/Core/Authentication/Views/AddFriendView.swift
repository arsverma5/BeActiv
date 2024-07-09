//
//  AddFriendView.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/7/24.
//

import SwiftUI
import Contacts

struct AddFriendsView: View {
    @StateObject private var contactManager = ContactManager()
    @State private var registeredContacts: [CNContact] = []
    @State private var showingAlert = false
    @EnvironmentObject private var friendsViewModel: FriendsViewModel
    private let appUserChecker = AppUserChecker() // Ensure correct instantiation
    
    var body: some View {
        VStack {
            if registeredContacts.isEmpty {
                Text("No friends to add")
            } else {
                List(registeredContacts, id: \.identifier) { contact in
                    HStack {
                        Text("\(contact.givenName) \(contact.familyName)")
                        Spacer()
                        Button("Add Friend") {
                            friendsViewModel.addFriend("\(contact.givenName) \(contact.familyName)")
                        }
                    }
                }
            }
        }
        .onAppear {
            contactManager.requestAccess { granted in
                if granted {
                    contactManager.fetchContacts { contacts in
                        appUserChecker.checkAppUsers(contacts: contacts) { registeredContacts in
                            self.registeredContacts = registeredContacts
                        }
                    }
                } else {
                    showingAlert = true
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Access Denied"), message: Text("Please enable contacts access in settings"), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("Add Friends")
    }
}

#Preview {
    NavigationStack {
        AddFriendsView()
            .environmentObject(FriendsViewModel())
    }
}




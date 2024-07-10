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
    @State private var searchResults: [User] = []
    @State private var isSearching: Bool = false
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
                            Task {
                                isSearching = true
                                searchResults = await friendsViewModel.searchFriend(by: "\(contact.givenName) \(contact.familyName)")
                                isSearching = false
                                
                                if let user = searchResults.first {
                                    friendsViewModel.addFriend(user)
                                }
                            }
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
        .alert(isPresented: $friendsViewModel.showAlert) {
            Alert(title: Text("Error"), message: Text(friendsViewModel.alertMessage), dismissButton: .default(Text("OK")))
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







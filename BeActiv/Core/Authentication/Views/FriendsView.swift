//
//  FriendsView.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//

import SwiftUI

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @State private var searchQuery: String = ""
    @State private var searchResults: [User] = []
    @State private var isSearching: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.friends) { friend in
                    HStack {
                        Image(systemName: friend.imageName)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(friend.name)
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
                
                HStack {
                    TextField("Search friend's name", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        Task {
                            isSearching = true
                            searchResults = await viewModel.searchFriend(by: searchQuery)
                            isSearching = false
                        }
                    }) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                .padding(.bottom)
                
                if isSearching {
                    ProgressView()
                } else {
                    List(searchResults) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.fullName)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            }
                            Spacer()
                            Button(action: {
                                viewModel.addFriend(user)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                NavigationLink(destination: AddFriendsView()) {
                    Text("Add Friends from Contacts")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.bottom)
                
            }
            .navigationBarTitle("Friends")
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            viewModel.loadFriends()
        }
    }
}

#Preview {
    FriendsView()
}







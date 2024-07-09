//
//  FriendsView.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/2/24.
//

import SwiftUI

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @State private var newFriendName: String = ""
    
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
                            Text("\(friend.stepCount) steps")
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
                
                HStack {
                    TextField("New friend's name", text: $newFriendName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        if !newFriendName.isEmpty {
                            viewModel.addFriend(newFriendName)
                            newFriendName = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                .padding(.bottom)
                
                NavigationLink(destination: AddFriendsView()) {
                    Text("Add Friends from Contacts")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Friends")
        }
    }
}

#Preview {
    FriendsView()
}


